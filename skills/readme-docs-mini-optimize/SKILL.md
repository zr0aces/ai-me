---
name: readme-docs-mini-optimize
description: Minimal, maintainable, professional repository documentation setup. Use this skill whenever the user wants to create, restructure, audit, or optimize repository documentation — including README, CHANGELOG, docs/ folder, GitHub templates, VERSION file, or AI-friendly repo files. Also trigger when the user asks "what docs should my repo have", "help me set up docs", "review my documentation structure", or wants a lean doc structure for a new or existing project.
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

### .github/ISSUE_TEMPLATE/bug_report.md

```markdown
### Current Behavior
### Expected Behavior
### Steps to Reproduce
### Environment
### Logs
```

### .github/ISSUE_TEMPLATE/feature_request.md

```markdown
### Problem
### Proposed Solution
### Alternatives
### Additional Context
```

### .github/pull_request_template.md

```markdown
## Summary
## Changes
## Testing
## Screenshots
```

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

Reference in `docs/deployment.md`:
```markdown
See `docs/deployment/` for example configs. Copy and adapt before use:
- `docs/deployment/.env.example` → `.env`
- `docs/deployment/docker-compose.yml.example` → `docker-compose.yml`
- `docs/deployment/nginx.conf.example` → `/etc/nginx/conf.d/app.conf`
```

---

### `docs/deployment/.env.example`

All required and optional vars. Placeholders only — no real secrets.

```bash
# App
APP_PORT=8080
APP_ENV=production
SECRET_KEY=change-me-in-production

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=myapp
DB_PASSWORD=change-me

# Cache (optional)
REDIS_URL=redis://localhost:6379
```

Rules:
- Every var in `.env` must appear here
- Mark optional vars with `# optional`
- Real `.env` → `.gitignore`. Only `docs/deployment/.env.example` committed.

---

### `docs/deployment/docker-compose.yml.example`

Working minimal example. Match actual services in the repo.

```yaml
version: "3.9"

services:
  app:
    image: myapp:latest
    ports:
      - "8080:8080"
    env_file:
      - .env
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: change-me
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

Rules:
- Reflect actual services only — don't invent
- `env_file: .env` pattern — no hardcoded secrets
- Match image names from real `docker-compose.yml` or `Dockerfile`

---

### `docs/deployment/nginx.conf.example`

Only add if nginx is used.

```nginx
server {
    listen 80;
    server_name example.com;

    # Redirect HTTP → HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate     /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;

    # Serve frontend static files
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
    }

    # Proxy API to backend
    location /api/ {
        proxy_pass http://app:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Adapt to actual project: SPA vs SSR, API path, port, SSL vs no SSL.

---

## 11. AI-Friendly Files

For repos developed heavily with AI tools, add these two files. They reduce hallucination and keep AI-generated code consistent.

### .github/instructions.md

```markdown
# AI Development Rules

- Follow existing architecture
- Do not duplicate code
- Update tests alongside code changes
- Update documentation when behavior changes
- Follow CalVer versioning
- Read VERSION file — do not hardcode versions
- Use single source of truth for all config
```

### docs/coding-standards.md

```markdown
# Coding Standards

## General
- Prefer simplicity over cleverness
- Avoid premature optimization
- Keep functions under 100 lines
- Prefer composition over inheritance

## Logging
- Structured logs only (JSON)
- Never log secrets or PII

## Security
- Validate all inputs at system boundaries
- Never log secrets
```

---

## Execution Checklist

**Step 0 — detect mode and app stack:**

```bash
# doc files
find . -name "*.md" -not -path "./.git/*" -not -path "./superpowers/*" \
  -not -path "./graphify-out/*" | sort

# deployment stack detection
ls docker-compose* Dockerfile* nginx* .env* 2>/dev/null
```

If 3+ doc files exist → **Existing Docs Mode**. Otherwise → **Greenfield Mode**.

Deployment example files needed (check stack detection output, all go in `docs/deployment/`):
- `.env` exists or env vars used → need `docs/deployment/.env.example`
- `docker-compose.yml` or `Dockerfile` exists → need `docs/deployment/docker-compose.yml.example`
- nginx referenced → need `docs/deployment/nginx.conf.example`

---

### Existing Docs Mode (repo already has docs)

Goal: reduce and consolidate — do NOT blindly add new files. **Never delete existing docs.**

1. **Audit** — list every `.md` file in `docs/`; note purpose, size, last-modified
2. **Merge redundant files** — e.g. `SETUP.md` + `INSTALL.md` → single `docs/development.md`; move originals to `docs/archived/`
3. **Trim bloated files** — cut prose, walls of text, outdated sections; commands > paragraphs
4. **Collapse shallow docs/ into README** — if `docs/` has files under ~20 lines each, absorb into README sections instead; move originals to `docs/archived/`
5. **Rename to standard names** only if content clearly maps (never rename speculatively)
6. **Archive, never delete** — files that duplicate content or add zero value go to `docs/archived/<original-name>.md`. Create `docs/archived/` if it doesn't exist. Add a one-line comment at the top of each archived file explaining why it was archived and what superseded it.
7. **Optimize into related docs** — if a file covers a topic partially handled elsewhere, merge its unique content into the existing doc, then archive the source file
8. **Add missing critical files only** — `VERSION` (if versioning exists but no file), `CHANGELOG.md` (if releases exist), `.github/instructions.md` (if AI-heavy repo), `docs/deployment/` examples if stack detected but examples absent (see Section 10)
9. Verify all internal links resolve
10. Report: files merged, trimmed, archived, renamed, added — and **why** for each action

**Reduction rules:**
- Fewer active files beats complete coverage
- One clear file beats two partial files
- If unsure whether to keep a section → cut it (but archive the source file, not delete)
- Never add a docs/ file just to match the "ideal structure" — only add if the content genuinely doesn't fit elsewhere
- `docs/archived/` is a graveyard, not a dumping ground — only move files there when their content is fully absorbed elsewhere or genuinely obsolete

---

### Greenfield Mode (new or near-empty repo)

1. Create `README.md` — trim to 1–2 pages max
2. Create `CHANGELOG.md` — Keep a Changelog format
3. Create `VERSION` — single source of truth
4. Create deployment examples in `docs/deployment/` based on stack (see Section 10):
   - `docs/deployment/.env.example` if env vars used
   - `docs/deployment/docker-compose.yml.example` if Docker used
   - `docs/deployment/nginx.conf.example` if nginx used
5. Create `docs/` files only as needed: architecture, development, deployment, configuration, decisions
6. Create GitHub templates — bug report, feature request, PR template
7. Add `docs/coding-standards.md` and `.github/instructions.md` if AI tools are used
8. Verify all internal links resolve
9. Report: files added, gaps remaining
