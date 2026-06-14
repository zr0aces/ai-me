---
name: readme-docs-full
description: Full comprehensive documentation structure for production-ready repositories. Manual trigger only — invoke only when user explicitly runs /readme-docs-full or requests this skill by name.

trigger: /readme-docs-full
---

# Full Repository Documentation Structure

Use when a repo needs complete, production-ready documentation — onboarding, architecture, deployment, operations, security, backup/recovery, and monitoring. No tribal knowledge left undocumented.

> **Never touch these directories:**
> - `superpowers/` / `skills/superpowers*`
> - `graphify-out/`

---

## 1. README.md

Keep lean. Link out to `docs/` for depth.

Must contain:
- Project overview and key features
- High-level tech stack
- Quick start / installation
- Basic configuration reference
- Documentation index linking to `docs/`
- Contribution entry points

Move all deep-dives, runbooks, and troubleshooting into `docs/`.

---

## 2. Full docs/ Structure

```text
docs/
├── getting-started/
│   ├── installation.md
│   ├── configuration.md
│   └── quickstart.md
├── architecture/
│   ├── overview.md
│   ├── data-flow.md
│   └── decisions.md
├── deployment/
│   ├── docker.md
│   ├── environment.md
│   └── release.md
├── operations/
│   ├── runbook.md
│   └── upgrade.md
├── monitoring/
│   ├── health-checks.md
│   ├── logging.md
│   └── alerts.md
├── security/
│   ├── authentication.md
│   └── secrets.md
├── recovery/
│   ├── backup.md
│   └── restore.md
├── troubleshooting/
│   └── common-issues.md
└── development/
    ├── setup.md
    ├── coding-standards.md
    └── testing.md
```

Create subdirs and files only when content exists to fill them. Empty placeholder files add no value.

---

## 3. Production Readiness Checklist

Verify and document each area:

### Deployment & Release
- Version strategy (CalVer `YYYY.M.MINOR`)
- Docker image tags, build steps, rollback procedure
- CI/CD pipeline steps

### Configuration & Secrets
- All environment variables with defaults
- Secrets management approach (`.env` structure, vault, etc.)
- Pydantic/config schema if applicable

### Monitoring & Diagnostics
- Health check endpoints
- Log structure, location, rotation
- Metrics and alerts (Telegram, PagerDuty, etc.)
- Debug commands and diagnostic steps

### Backup, Recovery & Security
- DB backup commands and schedule (e.g. `pg_dump`)
- Recovery validation steps
- Auth flows (JWT, sessions)
- Password hashing approach
- Authorization rules

---

## 4. Execution Steps

1. **Audit existing docs** — run then read each file found:
   ```bash
   [ -d ./docs ] && find ./docs -type f -name "*.md" \
     -not -path "*/graphify-out/*" -not -path "*/superpowers/*" | sort \
     || echo "no docs/ directory yet"
   ```
   Note topic and gaps per file.
2. **Map to structure** — assign each existing file to a subdir in Section 2; identify missing areas
3. **Create missing files** — only for areas with actual content to write (no placeholders)
4. **Update README** — ensure Documentation Index links to all active `docs/` files
5. **Validate** — all CLI commands, paths, and configs must match actual repo content
6. **Consolidate** — merge overlapping sections; archive obsolete docs:
   ```bash
   mkdir -p docs/archived
   ```
   Move files: `mv docs/old-file.md docs/archived/old-file.md`; add `<!-- Archived YYYY-MM-DD: superseded by <file> -->` at top
7. **Cross-link** — use relative paths: `[deployment.md](../deployment/docker.md)`
8. **Report** — list: Updated, Added, Removed, Key Improvements, Gaps Remaining
