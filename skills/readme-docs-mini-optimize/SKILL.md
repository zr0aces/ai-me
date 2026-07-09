---
name: readme-docs-mini-optimize
description: Minimal, maintainable, professional repository documentation setup. Manual trigger only — invoke only when user explicitly runs /readme-docs-mini-optimize or directly requests this skill by name.
trigger: /readme-docs-mini-optimize
---

# Minimal Repository Documentation

Goal: lean docs that support onboarding, development, releases, operations, and AI-assisted development — nothing more.

---

## Recommended File Structure

```text
repo/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
├── VERSION

├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── pull_request_template.md
│   ├── instructions.md          ← AI dev rules
│   └── workflows/

├── docs/
│   ├── architecture.md
│   ├── development.md
│   ├── deployment.md
│   ├── configuration.md
│   ├── decisions.md
│   ├── coding-standards.md     ← AI dev standards
│   ├── deployment/             ← example configs (only what app needs)
│   │   ├── .env.example
│   │   ├── docker-compose.yml.example
│   │   └── nginx.conf.example
│   └── archived/               ← superseded docs (never delete, archive here)

└── scripts/
    ├── release.sh
    └── sync-version.sh
```

Add files only when the repo genuinely needs them. More docs = more maintenance burden.

> **Excluded directories** — never audit, scan, or modify these:
> - `superpowers/` (or any `skills/superpowers*` path)
> - `graphify-out/`

---

## 1. README.md

**Target: 1–2 pages maximum.** Nobody reads a 20-page README.

```markdown
# Project Name

Short one-line description.

## Features

- Feature A
- Feature B

## Quick Start

### Prerequisites
### Installation
### Configuration
### Run

## Architecture

See docs/architecture.md

## Development

See docs/development.md

## Deployment

See docs/deployment.md

## Versioning

Uses CalVer: YYYY.M.MINOR  (e.g. 2026.6.1)

## License
```

Rules:
- No wall of text
- No screenshots unless they add real clarity
- Link to docs/ for depth; keep README surface-level

---

## 2. CHANGELOG.md

Follow [Keep a Changelog](https://keepachangelog.com) format exactly.

```markdown
# Changelog

## [2026.6.3]

### Added
- New dashboard

### Changed
- Improved authentication

### Fixed
- Session handling issue
```

---

## 3. VERSION

Single source of truth for the version. Everything reads from this file.

```text
2026.6.1
```

What must read VERSION:
- Frontend (display in About/footer)
- Backend (API version header)
- Docker image tag
- Release script
- CI/CD pipeline

Never hardcode version strings elsewhere.

---

## 4. docs/architecture.md

High-level only. No implementation details.

```markdown
# Architecture

## Components

- Frontend
- Backend
- Database
- Cache

## Data Flow

User → API → Service → Database

## External Integrations

- OAuth
- SMTP
- S3
```

---

## 5. docs/development.md

Developer onboarding. Commands only — no prose.

```markdown
# Development

## Setup
make install

## Run
make dev

## Test
make test

## Lint
make lint

## Build
make build
```

---

## 6. docs/deployment.md

Operations guide.

```markdown
# Deployment

## Environment Variables
## Docker
## Kubernetes (optional)
## Backup
## Restore
## Upgrade
```

---

## 7. docs/configuration.md

All config options in one table.

```markdown
# Configuration

| Variable | Required | Default | Description       |
|----------|----------|---------|-------------------|
| APP_PORT | Yes      | 8080    | HTTP port         |
| DB_HOST  | Yes      | —       | Database host     |
```

---

## 8. docs/decisions.md

Lightweight Architecture Decision Records (ADR). Invaluable after 6–12 months.

```markdown
# Decisions

## 2026-06-12 — Use PostgreSQL

Reason: reliability, ecosystem
Alternatives considered: MySQL, SQLite
```

---

## 9. GitHub Templates

Three files: `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`, `.github/pull_request_template.md`. Bodies in `references/templates.md` §GitHub Templates — load it and copy verbatim.

---

## 10. Deployment Example Files

All example files live in `docs/deployment/`. Add only when app actually uses that technology.

```bash
# detect stack
ls docker-compose* Dockerfile* nginx* .env* 2>/dev/null
grep -r "docker\|nginx\|postgres\|redis" docker-compose.yml Dockerfile 2>/dev/null | head -5
```

**Decision table:**

| File | Location | Add when |
|------|----------|----------|
| `.env.example` | `docs/deployment/.env.example` | Any env vars used (`os.environ`, `process.env`, `.env` exists, or compose has `env_file`) |
| `docker-compose.yml.example` | `docs/deployment/docker-compose.yml.example` | `docker-compose.yml` or `Dockerfile` exists |
| `nginx.conf.example` | `docs/deployment/nginx.conf.example` | Nginx used as reverse proxy, static server, or in docker-compose |

**Never add** speculatively. No Docker in project → no `docker-compose.yml.example`.

Bodies for all three example files, plus the `docs/deployment.md` reference block, are in `references/templates.md` §Deployment Example Files — load it and adapt to the actual stack detected above before writing.

---

## 11. AI-Friendly Files

Add when: user explicitly requests AI-friendly files, OR repo shows AI tool usage (`.claude/`, `CLAUDE.md`, `.github/copilot*` exist, or AI tool commit authors detected). They reduce hallucination and keep AI-generated code consistent.

Two files: `.github/instructions.md` and `docs/coding-standards.md`. Bodies in `references/templates.md` §AI-Friendly Files — load it and copy verbatim (adapt only if the repo's actual stack contradicts a rule, e.g. a Go repo shouldn't get a JS-flavored line).

---

## Execution Checklist

**Step 0 — detect mode and app stack:**

```bash
# count .md files inside docs/ only (mode detection)
find . -type f -name "*.md" -path "./docs/*" \
  -not -path "./superpowers/*" -not -path "./graphify-out/*" | sort

# root-level doc files for awareness (not counted for mode)
find . -maxdepth 1 -type f -name "*.md" \
  -not -path "./superpowers/*" -not -path "./graphify-out/*" | sort

# deployment stack detection
find . -type f \( -name "docker-compose*" -o -name "Dockerfile*" \
  -o -name "nginx*" -o -name ".env*" \) \
  -not -path "./.git/*" -not -path "./superpowers/*" \
  -not -path "./graphify-out/*" | sort
```

If 1+ `.md` files found inside `docs/` → **Existing Docs Mode**. Otherwise → **Greenfield Mode**.

Deployment example files needed (check stack detection output, all go in `docs/deployment/`):
- `.env` exists or env vars used → need `docs/deployment/.env.example`
- `docker-compose.yml` or `Dockerfile` exists → need `docs/deployment/docker-compose.yml.example`
- nginx referenced → need `docs/deployment/nginx.conf.example`

---

### Existing Docs Mode (repo already has docs)

Goal: reduce and consolidate — do NOT blindly add new files. **Never delete existing docs.**

Steps are sequential — complete each before starting the next.

1. **Audit** — run the commands below; read every file found; note topic, line count, and overlap (same commands/steps appearing in two files = overlap):
   ```bash
   find ./docs -type f -name "*.md" | sort
   wc -l docs/*.md 2>/dev/null
   ```
2. **Merge redundant files** — same topic = same commands or steps appear in both files (e.g. `SETUP.md` + `INSTALL.md` both show `npm install`). Different topics = different commands, different audience. When merging: copy all content into target file first, verify nothing lost, then move source to `docs/archived/`.
3. **Trim bloated files** — files over 100 non-blank lines: cut explanatory paragraphs, keep commands/tables/headers. Do not cut technical steps or commands.
4. **Collapse tiny files into README** — count non-blank lines: `grep -cv "^[[:space:]]*$" file.md`. If result ≤ 20 and topic fits a README section → absorb into README; move original to `docs/archived/`.
5. **Rename to standard names** — only if the file's H1 heading directly states the standard name (e.g. `# Development Setup` → `development.md`). Never rename by guessing topic from content.
6. **Archive, never delete** — absorbed/obsolete files → `docs/archived/<original-name>.md`. Create `docs/archived/` if missing. Before archiving: run `grep -r "<filename>" . --include="*.md"` to find inbound links; update any found links to point to new location. Add at top: `<!-- Archived YYYY-MM-DD: content merged into <target file> -->`.
7. **Merge partial overlaps** — file covers topic partially handled elsewhere: copy unique content into existing doc, verify no content lost, then archive source.
8. **Add missing critical files only** — `VERSION` (if versioning exists but no file), `CHANGELOG.md` (if releases exist), `.github/instructions.md` (if AI tools detected per Section 11 rules), `docs/deployment/` examples if stack detected but examples absent (see Section 10).
9. **Verify links** — find all relative links then confirm each path exists:
   ```bash
   grep -roh "\](\.\/[^)]*)" docs/ README.md 2>/dev/null | sed 's/](\.\///' | sed 's/)//'
   # then for each path found:
   find . -path "./<path>" | head -1
   ```
10. **Report** — one line per file actioned: `[merged|trimmed|archived|renamed|added] <filename> — <why>`

**Reduction rules:**
- Fewer active files beats complete coverage
- One clear file beats two partial files
- If unsure whether to keep a section → cut it (but archive the source file, not delete)
- Never add a docs/ file just to match the "ideal structure" — only add if the content genuinely doesn't fit elsewhere
- `docs/archived/` is a graveyard, not a dumping ground — only move files there when their content is fully absorbed elsewhere or genuinely obsolete

---

### Greenfield Mode (new or near-empty repo)

Run Step 0 stack detection first. Use its output for steps 4 and 5 below.

1. Create `VERSION` — single source of truth (Section 3)
2. Create `README.md` — use template from Section 1; read source files to populate (not placeholder text)
3. Create `CHANGELOG.md` — Keep a Changelog format (Section 2)
4. Create `docs/` files — run detection commands below; create file only if condition is met:

| File | Detect with | Create if |
|------|-------------|-----------|
| `docs/development.md` | `find . -name "Makefile" -o -name "package.json" -o -name "*.sh" \| head -3` | Any runnable entry point found |
| `docs/architecture.md` | `find . -maxdepth 2 -type d \| wc -l` | 3+ source subdirectories exist |
| `docs/deployment.md` | Step 0 stack detection output | Docker, cloud config, or server config found |
| `docs/configuration.md` | `grep -r "os.environ\|process.env\|getenv" . --include="*.py" --include="*.js" --include="*.ts" \| wc -l` | 3+ env var references found |
| `docs/decisions.md` | Always | Always create — captures future decisions |

5. Create deployment examples from Step 0 stack detection output (see Section 10):
   - `docs/deployment/.env.example` — if `.env*` files or env var references found
   - `docs/deployment/docker-compose.yml.example` — if `docker-compose*` or `Dockerfile*` found
   - `docs/deployment/nginx.conf.example` — if `nginx*` found
6. Create `.github/` templates — bug report, feature request, PR template
7. Add `.github/instructions.md` and `docs/coding-standards.md` if AI tools detected (see Section 11) or user requested
8. **Verify links** — find relative links and confirm each path exists:
   ```bash
   grep -roh "\](\.\/[^)]*)" docs/ README.md 2>/dev/null | sed 's/](\.\///' | sed 's/)//'
   ```
9. **Report** — one line per file created: `added <filename> — <why>`
