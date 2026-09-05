---
name: update-dependencies
description: Upgrade every package.json in a repo (root and all workspaces) to the latest stable versions that stay compatible with the codebase, regenerate the lockfile, and verify with the repo's own typecheck/lint/test/build scripts. Bumps within the current major by default and reports available majors separately instead of taking them. Use this whenever the user asks to update, upgrade, or bump dependencies, "get packages to latest", refresh a lockfile, deal with outdated or stale deps, or asks which packages are behind — even if they only mention one package or don't say "package.json".
---

# Update dependencies

Goal: every dependency on its latest stable release that the codebase still works with, proven by the repo's own checks — not by hope.

Default policy: **stay inside the current major.** Majors carry breaking changes that need reading release notes and often code edits; taking them silently is how a "routine bump" turns into a broken afternoon. Collect them in a report and let the user choose. Take a major only when the user asks for it.

## 1. Map the repo

Find every manifest and the package manager before touching anything.

```bash
find . -name package.json -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/dist/*'
ls package-lock.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null
```

The lockfile decides the tool — `npm`, `yarn`, `pnpm`, `bun`. Never mix. If no lockfile exists, ask before creating one; picking a package manager for someone is a decision, not a bump.

Yarn needs one more question, because Yarn 1 and Yarn 2+ ("Berry") are different tools:

```bash
yarn --version        # 1.x = classic, 2+/3+/4+ = Berry
ls .yarnrc.yml        # present = Berry
```

Berry removed `yarn outdated`; running it there just errors. Berry's equivalent is `yarn upgrade-interactive`, which needs `plugin-interactive-tools` on Yarn 2/3 (built in on 4). If it's unavailable, fall back to reading versions off the registry directly (`npm view <pkg> version` works regardless of which package manager owns the repo).

Workspaces (`workspaces` field, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`) mean the manifests are one dependency graph. Upgrade a shared package to the **same version everywhere** — split versions across workspaces cause duplicate installs and confusing type errors.

Record the baseline so you can prove you didn't break anything that already worked:

```bash
git status --porcelain   # must be clean, or stop and ask
```

Install before anything else, then run the repo's checks once. A test suite already red before you started is not your regression, and knowing that up front saves an hour of chasing.

The install is not optional: `npm outdated` and its equivalents inspect the **installed tree**, not the manifest. On a fresh clone with no `node_modules`, they report nothing at all — and "nothing outdated" on a two-year-old repo is a result you should never believe. If the check comes back empty, confirm the install actually happened before reporting it.

## 2. Find what's outdated

```bash
npm outdated --json    # or: yarn outdated --json / pnpm outdated --format json / bun outdated
```

`npm outdated` gives `current`, `wanted` (satisfies your range), `latest`. Split the list in two:

- **In-major**: `latest` shares the major with `current` (or `current` is `0.x` and the minor matches — in semver `0.x`, the minor is the breaking segment, so treat `0.4 → 0.5` as a major).
- **Major**: everything else. These go in the report, not the diff.

`npm outdated` exits non-zero when anything is outdated. That's success, not failure — don't let it abort a script.

Skip anything pinned deliberately. `package.json` is strict JSON and cannot carry comments, so the pin's reasoning always lives somewhere else — look for:

- an **exact version** (no `^` or `~`) in a file where everything else uses ranges
- an `overrides` (npm/bun), `resolutions` (yarn/pnpm), or `pnpm.overrides` entry
- `npm-shrinkwrap.json`, which exists specifically to freeze the tree
- a mention in `README.md`, `CLAUDE.md`, `AGENTS.md`, or a `renovate.json` / `.dependabot` ignore rule

Pins usually encode a bug someone already hit. If you can't find the reason, leave the pin alone and say so in the report — an unexplained pin is a question for the user, not a bump to make on their behalf.

## 3. Apply the in-major upgrades

Most in-major upgrades need no `package.json` edit at all. A `^1.2.0` range already permits `1.9.0`, so the upgrade lives entirely in the lockfile:

```bash
npm update            # or: pnpm update / yarn up / bun update
```

Edit `package.json` only when `latest` falls **outside** the existing range — a `~1.2.0` that needs `1.9.0`, or an exact pin you've been asked to move. Rewriting ranges that already permit the new version produces a diff full of churn that reviewers have to read and learn nothing from.

When you do edit, preserve the range style the file already uses (`^`, `~`, exact). Matching the file's existing convention matters more than your preference — a repo that pins exact versions did it on purpose.

Then regenerate the lockfile with a normal install (`npm install`, `pnpm install`, `yarn`, `bun install`), not `--force` and not a hand-edited lockfile.

Watch for these while installing:

- **Peer dependency warnings** — a package now demanding a React or TypeScript version the repo doesn't have. Don't paper over it with `--legacy-peer-deps`; that hides a real incompatibility until runtime. Drop that package back to the last version whose peers are satisfied and note it.
- **`engines` mismatches** — a package requiring a newer Node than the repo runs. Same treatment: hold it back, report the Node version it wants.
- **Deprecation notices** during install. Worth surfacing even when nothing breaks.

## 4. Verify with the repo's own checks

Read `scripts` in the root `package.json` and run what exists, in this order (cheapest signal first):

1. typecheck / `tsc --noEmit`
2. lint
3. test
4. build

Compare against the baseline from step 1: only *new* failures count.

**On a new failure, don't guess which package caused it.** Bisect, using git as the undo rather than hand-editing your way back:

```bash
git checkout -- package.json package-lock.json   # back to the known-good baseline
# reapply half the upgrades
npm install
npm run <the failing check>
```

Failure persists → the culprit is in the half you kept. Failure gone → it's in the other half. A few rounds isolates it faster than reading stack traces, and starting each round from a clean checkout keeps the halves honest — hand-reverting drifts, and a drifted bisect points at the wrong package with total confidence.

Once isolated, either apply the small call-site change the package's changelog documents, or hold that package at its previous version and say why.

Ending with two packages held back and everything green beats ending with everything upgraded and a red build.

## 5. Report

```markdown
## Upgraded (N packages)
| Package | From | To | Workspace |

## Held back
| Package | Wanted | Kept at | Why |
(peer conflict, engines, test failure — name the actual reason)

## Major versions available (not taken)
| Package | Current | Latest | Breaking changes |
(one line each on what the major changes, from its release notes)

## Verification
typecheck / lint / test / build — result of each, and any failure that
was already failing before the upgrade.
```

Then ask whether to take any of the majors. If the user says yes, do **one major at a time**: upgrade, read its migration guide, apply the code changes it requires, run the full check suite, commit. One-at-a-time is slower per package and far faster overall, because a failure has exactly one possible cause.

## Notes

- Node itself, CI config, and Docker base images are out of scope unless the user asks — this skill touches `package.json` and the lockfile.
- Security fixes are the one case worth breaking the in-major rule for: if `npm audit` shows a vulnerability only fixable by a major, say so explicitly rather than leaving it in the "not taken" list.
- Don't commit unless asked. Leave the diff and the report.
