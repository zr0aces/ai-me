---
name: version-calver-control
description: Automated Calendar Versioning (CalVer YYYY.M.MINOR) system with a single source of truth, automated synchronization, and release verification.
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
*   **M**: Calendar Month (1-2 digits, no leading zero, e.g., `6` for June)
*   **MINOR**: Incremental release counter for the current month, starting at `1` and resetting to `1` when a new month begins.

---

## 🔑 2. Single Source of Truth

To prevent version drift, establish a single central file at the root of the repository as the version source of truth:
*   **File:** `VERSION` (containing only the CalVer string, e.g., `2026.6.2`).
*   No other component should define version strings statically; instead, they must derive their version from this file during builds or sync checks.

---

## 🛠️ 3. Automated Scripts

Implement the following automated scripts in the `scripts/` directory to manage versioning and deployments:

### `sync-version.mjs`
Responsible for propagating the version from the single source of truth (`VERSION`) to all component configuration files.
*   **Manifests Updated:**
    *   `backend/pyproject.toml` -> Python project metadata and API version.
    *   `frontend/package.json` -> Node manifest version.
    *   `frontend/package-lock.json` -> Lockfile dependency manifest version.
    *   `README.md` -> Project documentation.
*   **Validation Check:** Supports a `--check` flag that checks if any files have diverged from the `VERSION` file, exiting with a non-zero exit code on failure to fail build/CI pipelines.

### `release.mjs`
Responsible for the release lifecycle.
*   **Version Incrementing:** Automatically increments the `MINOR` version if releasing in the current month, or resets to `1` if a new month/year begins.
*   **Source Bumping:** Writes the new version back to the `VERSION` file.
*   **Synchronization:** Invokes `sync-version.mjs` to propagate changes.
*   **Build Artifacts:** Optionally builds version-tagged Docker compose images (`--build`) and creates Git commits and tags (`--tag`).

---

## 🔗 4. Codebase Integration Workflow

1.  **Backend Integration:** Configure the API package to parse its version dynamically from `backend/pyproject.toml` (e.g., via `tomllib` in Python) so editable installs or runtime environments read the version without reinstalling.
2.  **Frontend Integration:** Import `package.json` inside the frontend bundler config (e.g. `vite.config.ts`) and define a compiler constant like `__APP_VERSION__` to display the version dynamically in the UI.
3.  **Docker compose Integration:** Tag backend and frontend images with the version (e.g. `image: nexsignl-api:${NEXSIGNL_VERSION:-latest}`) and export the `NEXSIGNL_VERSION` environment variable during container builds.
4.  **Documentation Integration:** Automatically update `README.md` using the sync script to guarantee up-to-date deployment guides.
5.  **CI/CD Gating:** Run `node scripts/sync-version.mjs --check` as a pre-build validation check to prevent version inconsistencies from getting committed.
