# ai-me

`ai-me` is a development environment configuration repository for AI agents. It contains custom agent skills and guidelines to ensure consistent and optimized development workflows.

## 🛠️ Technology Stack & Tools

*   **Markdown (`.md`)**: Used to define structured agent guidelines.
*   **RTK (Rust Token Killer)**: Hook-based CLI proxy for token optimization during development operations.
*   **Symlinking Script**: Automates linking agent skills into local config directories for various AI tools.

## 📅 Quick Start

1.  **Clone the repository**:
    ```bash
    git clone git@github.com:zr0aces/ai-me.git
    cd ai-me
    ```

2.  **Verify token-optimization hook**:
    ```bash
    rtk --version
    rtk gain
    ```

3.  **Link skills to agent configurations**:
    Execute the linking script to sync the skills to your local AI tool folders (e.g., Claude, Gemini, Copilot):
    ```bash
    ./scripts/link-skills.sh
    ```
    Use `--dry-run` to preview the symlinks without making changes, or `--unlink` to remove existing links.

## ⚙️ Available Skills

The following core agent skills are defined in this repository:

*   **[date-display-format](skills/date-display-format/SKILL.md)** — Standardized date rendering (`dd MMM yyyy`) and client-server timezone synchronization.
*   **[debug-mantra](skills/debug-mantra/SKILL.md)** — Four-step debugging discipline (reproduce, trace, falsify, ledger).
*   **[logo-design](skills/logo-design/SKILL.md)** — Guidelines for programmatic brand assets (SVGs, Pillow scripts) and UI theme variables.
*   **[post-mortem](skills/post-mortem/SKILL.md)** — Canonical engineering post-mortems for documenting root cause analysis (RCA).
*   **[readme-docs-full](skills/readme-docs-full/SKILL.md)** — Comprehensive documentation structures for production-ready repos.
*   **[readme-docs-mini-optimize](skills/readme-docs-mini-optimize/SKILL.md)** — Lean, optimized documentation setup (1-2 page README, CalVer, instructions).
*   **[scrutinize](skills/scrutinize/SKILL.md)** — Outsider end-to-end review of proposed changes (PRs, plans, code paths).
*   **[version-calver-control](skills/version-calver-control/SKILL.md)** — Single source of truth Calendar Versioning (CalVer `YYYY.M.MINOR`) and synchronization.
