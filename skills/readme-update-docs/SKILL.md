---
name: readme-update-docs
description: Project documentation synchronization and review strategy for README.md and documentation files under /docs.
---

# Documentation Modernization & Production Readiness Skill

Use this skill when you need to perform a comprehensive audit and update of the repository's documentation. This ensures that the system is fully documented for production readiness, operations, security, backup/recovery, and developer onboarding, with no tribal knowledge required.

---

## 📅 1. README Requirements

Keep the root `README.md` clean, concise, and focused on developer onboarding. It must contain only:
*   Project overview and key features.
*   High-level technology stack.
*   Quick start and installation steps.
*   Basic configuration reference.
*   A clean Documentation Index linking to files under `docs/`.
*   Entry points for contributions.

Move deep-dives, architectures, deployment runbooks, and troubleshooting guides into subdirectories under `docs/`.

---

## 🛠️ 2. Documentation Structure

Organize all documentation under the following logical subdirectory hierarchy inside the `docs/` folder:

```text
docs/
├── getting-started/
├── architecture/
├── deployment/
├── operations/
├── monitoring/
├── security/
├── recovery/
├── troubleshooting/
└── development/
```

> [!NOTE]
> The `docs/superpowers/` directory is used for internal build plans and must remain untouched. Do not relocate, modify, or delete any files inside this directory.

---

## 🔒 3. Production Readiness Checklists

When auditing or creating documents, verify and document:

### A. Deployment & Release Workflow
*   Automated version control rules (e.g. CalVer `YYYY.M.MINOR`).
*   Docker image tag structures, build steps, and rollback strategies.

### B. Configuration & Secrets
*   Environment variables, Pydantic Settings defaults, and override parameters.
*   Guidance on secrets management (such as `.env` structure).

### C. Monitoring & Diagnostics
*   Health checks, logging structure, metrics, and alerts (e.g., Telegram integration).
*   Debugging commands, common diagnostics, and logs location.

### D. Backup, Recovery, & Security
*   Disaster recovery, DB backup commands (e.g. `pg_dump` schedules), and recovery validations.
*   Authentication flows (JWT), password hashing (bcrypt), and authorization parameters.

---

## 🧹 4. Verification & Cleanup

1.  **Validate Code Examples:** All CLI commands, path directories, and config files mentioned must match the actual repository content.
2.  **No Duplicate Content:** Consolidate overlapping sections and delete obsolete documents or dead links.
3.  **Cross-Linking:** Use clean relative paths (e.g., `[deployment.md](deployment.md)`) for markdown linkages.

---

## 📝 5. Deliverables

Every audit must produce:
*   Updated or newly created docs under the appropriate `docs/` hierarchy.
*   A summary report listing **Updated Files**, **Added Files**, **Removed Files**, **Key Improvements**, and **Gaps Identified** (such as missing security or disaster recovery procedures).
