# ai-me

`ai-me` is a development environment configuration repository for AI agents. It contains custom agent skills and guidelines to ensure consistent and optimized development workflows.

## 🛠️ Technology Stack & Tools

*   **Markdown (`.md`)**: Used to define structured agent guidelines.
*   **RTK (Rust Token Killer)**: Hook-based CLI proxy for token optimization during development operations.

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

## ⚙️ Available Skills

The following core agent skills are defined in this repository:
*   [date-display-format](skills/date-display-format/SKILL.md) - Date formatting standard (`dd MMM yyyy`).
*   [logo-design](skills/logo-design/SKILL.md) - Logo and brand system guidelines.
*   [readme-update-docs](skills/readme-update-docs/SKILL.md) - Documentation audit workflows.
*   [version-calver-control](skills/version-calver-control/SKILL.md) - Calendar versioning specification.
