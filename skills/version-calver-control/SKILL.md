---
name: version-calver-control
description: Automated Calendar Versioning (CalVer YYYY.M.MINOR) system with a single source of truth, automated synchronization, and release verification. Manual trigger only — invoke only when user explicitly runs /version-calver-control or requests this skill by name.
trigger: /version-calver-control
---

# CalVer Version Control Skill

Use this skill when you need to configure, synchronize, or manage the Calendar Versioning (CalVer) system across all system components including frontend, backend, Docker images, and documentation.

---

## 📅 1. CalVer Specification

Versions must follow the CalVer format:
```
YYYY.M.MINOR
```
*   **YYYY**: Calendar Year (4 digits, e.g., `2026`)
*   **M**: Calendar Month (1-2 digits, no leading zero — e.g., `6` for June, `10` for October, never `06`)
*   **MINOR**: Incremental release counter for the current month, starting at `1` and resetting to `1` when a new month begins.

---

## 🔑 2. Single Source of Truth

To prevent version drift, establish a single central file at the root of the repository as the version source of truth:
*   **File:** `VERSION` (containing only the CalVer string, e.g., `2026.6.2`).
*   No other component should define version strings statically; instead, they must derive their version from this file during builds or sync checks.

---

## 📄 2a. VERSION File Bootstrap

**Always check for VERSION file before any versioning work.**

```bash
if [ -f VERSION ]; then
  echo "VERSION exists: $(cat VERSION)"
else
  echo "NOT FOUND — must create before proceeding"
fi
```

**If VERSION does not exist:**

1. Check for existing version strings in the repo:
   ```bash
   grep -r "version" pyproject.toml package.json setup.cfg setup.py 2>/dev/null | head -10
   ```
2. If version found → ignore legacy semver fields; always derive CalVer from current date:
   ```bash
   # YYYY.M.1 — M has no leading zero
   echo "$(date +%Y).$(date +%-m).1" > VERSION
   ```
3. If no version found → same: use current date:
   ```bash
   echo "$(date +%Y).$(date +%-m).1" > VERSION
   ```
4. Commit: `chore: add VERSION file (CalVer YYYY.M.MINOR)`

**Known gap in existing `release.mjs` implementations:** both reference implementations below (HausHQ, HausVis) fall back to a *hardcoded literal* (e.g. `'2026.7.1'`) when `VERSION` is missing and `package.json` has no version either — not the current-date derivation this section recommends. That hardcoded literal goes stale the moment the calendar moves past it. If you're setting up `release.mjs` fresh, use the current-date fallback above instead; if you're touching an existing one, flag the hardcoded literal to the user rather than silently trusting it.

**If VERSION exists:**

1. Read current value
2. Validate format matches `YYYY.M.MINOR` — fix if malformed
3. Proceed with sync or bump as requested

**Never skip this check.** All downstream scripts depend on VERSION existing.

---

## 🛠️ 3. Automated Scripts

Implement `release.mjs` and `sync-version.mjs` in the `scripts/` directory. Node/TypeScript projects are the common case in practice — both reference implementations below are real, verified `.mjs` scripts (ES modules, `fs`/`path`/`fileURLToPath`/`execSync`, no external deps), not Python or Vite. If the target project uses a different stack, translate the same logic rather than assuming Python `pyproject.toml` or a Vite build.

### `release.mjs`
Owns version *incrementing* only — it never touches deployment artifacts (no Docker build step, no `--build`/`--tag` flags; those were speculative in an earlier draft of this skill and don't exist in either real implementation).

*   **Reads the old version** from `VERSION`, falling back to `package.json`'s `version` field if `VERSION` is missing, falling back again to a hardcoded literal if neither exists (see the known-gap note in §2a — that literal should really be a current-date derivation, but isn't in practice).
*   **`--help` / `-h`** prints usage and exits.
*   **`--version <val>` / `-v <val>`** manually overrides the computed version (e.g. for a hotfix release out of normal cadence).
*   **Otherwise, bumps automatically:** parses `YYYY.M.MINOR` out of the old version, compares `YYYY.M` against the *system* date (`now.getFullYear()` / `now.getMonth()+1`) — never trusts the VERSION file's own month. Same month → `MINOR + 1`. Different month/year → reset to `YYYY.M.1` using the current date.
*   **Writes the new version** to `VERSION`, then `execSync`s `sync-version.mjs` in the same directory to propagate it everywhere else.
*   **Prints, but does NOT run, the finishing git commands** (`git add ...`, `git commit`, `git tag -a`, `git push origin main --tags`) — it's a deliberate stop short of pushing. A version-bump script that auto-pushes and auto-tags removes the last human checkpoint before a release goes out; leaving those as copy-paste instructions keeps a person in the loop for the one step that's hardest to undo. Don't "improve" this into auto-run without the user explicitly asking for it.

### `sync-version.mjs`
Propagates `VERSION`'s value to every file that duplicates it. **The exact file list is project-specific — discover it per-repo rather than assuming a fixed set.** Two real, verified examples, at opposite ends of the complexity range:

*   **HausHQ** (single Next.js app, no separate frontend/backend split): validates the version against a strict CalVer regex before doing anything (`/^(?<year>2\d{3})\.(?<month>[1-9]|1[0-2])\.(?<minor>\d+)$/`, exits 1 with an error if it doesn't match), then syncs exactly two targets — root `package.json`'s `version` field, and a fixed sentence in `README.md` (`` Uses CalVer: `YYYY.M.MINOR` (e.g. `X.Y.Z`). ``). Supports `--check`: exits `0` if everything already matches, `1` and prints each divergence otherwise (no writes happen in check mode) — this is the CI-gate pattern, use it as the template when a project needs one.
*   **HausVis** (monorepo-style: root + `frontend/` + `backend/`, each with its own `package.json`): syncs *three* package.json files (root, `frontend/`, `backend/`), `README.md` (a different pattern — `**Version: vX.Y.Z**`), `docs/deployment/docker-compose.yml` (both a `Version: X.Y.Z` comment line and every `backend:X.Y.Z`/`frontend:X.Y.Z` Docker image tag), three specific docs under `docs/` matching two alternate "Version:" header styles plus a footer pattern (`*HausVis vX.Y.Z`), and two static HTML guide files under `frontend/public/docs/`. **Has no `--check` flag at all** — every run just writes, there's no CI-gate mode here. That's a real gap relative to HausHQ's version, not a design choice to copy.
*   Do NOT edit any `package-lock.json`/`pnpm-lock.yaml` directly — those are auto-generated. Re-run the package manager's install step after a version bump if the lockfile needs to reflect it (usually it doesn't, since only the `version` field changes).
*   When writing a new `sync-version.mjs`, prefer including a `--check` flag from the start (cheap to add, expensive to retrofit once nothing enforces it) — see the CI/CD guidance below.

---

## 🔗 4. Codebase Integration Workflow

How the rest of the app actually reads the version back out, once `sync-version.mjs` has propagated it — verified against real Next.js/TypeScript usage, not a generic template.

1.  **Server-side/build-time read via JSON import.** The simplest correct pattern in a Node/TypeScript project: import `package.json` directly wherever the version is needed, no filesystem read, no extra build step. Requires `"resolveJsonModule": true` in `tsconfig.json` (check it's set before assuming this works). Example, from a real Next.js server component reading the version into a layout passed down to a client component:
    ```typescript
    import packageJson from '../../../package.json'
    // ...
    return <AdminLayout version={packageJson.version}>{children}</AdminLayout>
    ```
    This is preferable to a raw `fs.readFileSync('VERSION')` at runtime: it's resolved and bundled at build time, works identically in server and edge runtimes, and needs zero new dependencies. Reserve a runtime `VERSION`-file read for tooling that genuinely runs outside the app's own build (health-check scripts, deploy pipelines).

2.  **Client-side display.** If a version badge needs to render in a client component, don't read the file there directly — pass it down as a prop from the server component/layout that already imported `package.json` (as above). A hardcoded literal in a client component (`v2026.7.0`) is the most common way this drifts: it looks correct at the moment it's written and then silently goes stale on every subsequent release, since nothing forces it to be touched again. If you find a literal version string anywhere in the UI, trace whether it's wired to `package.json`/`VERSION` or just typed in — the latter is a bug, not a style choice.

3.  **Docker Compose Integration:** Pass version via `docker-compose.yml` using an env var set from `VERSION` before running compose:
    ```bash
    # Guard: fail fast if VERSION missing rather than silently deploying :latest
    [ -f VERSION ] || { echo "ERROR: VERSION file not found"; exit 1; }
    export APP_VERSION=$(cat VERSION)
    docker compose up -d
    ```
    In `docker-compose.yml`: `image: myapp-api:${APP_VERSION:-latest}`

    **Warning:** Do not rely on `:-latest` fallback in production — it masks a missing VERSION file and may deploy a stale image. The guard above prevents this. (HausVis's `sync-version.mjs` takes a different, complementary approach — it bakes the version directly into `docs/deployment/docker-compose.yml`'s image tags at sync time rather than relying on an env var at `compose up` time. Either is fine; don't do both to the same file, since the second one to run wins.)

4.  **Documentation Integration:** Whatever docs carry a version string (`README.md` at minimum; HausVis-style projects may have several more) belong in `sync-version.mjs`'s target list, not manually updated. If a doc's version drifts, that's a missing sync target, not a one-off fix.

5.  **CI/CD Gating:** Only meaningful where `sync-version.mjs` actually implements `--check` (confirmed in HausHQ, absent in HausVis — verify before assuming it exists). Where it does:
    ```yaml
    - name: Verify version consistency
      run: node scripts/sync-version.mjs --check
    ```
    Exit code 1 fails the pipeline. Where it doesn't exist yet, adding `--check` is a small, high-value change worth suggesting — it's the difference between "versions can silently drift" and "drift fails CI."
