# ai-handoff.json Schema

Load this file during [Step 6 — Portfolio Generation](../SKILL.md#6-portfolio-generation), when writing `ai-handoff.json`. It is the machine-primary artifact — any downstream agent should be able to read only this file and get the full picture of one reviewed repository.

```json
{
  "name": "string",
  "last_reviewed": "YYYY-MM-DD",
  "overall_score": 0,
  "score_breakdown": { "functionality": 0, "documentation": 0, "ux_ui": 0, "security": 0, "portfolio_readiness": 0 },
  "verified": true,
  "key_benefits": ["string", "..."],
  "features": ["string", "..."],
  "tech_stack": ["string", "..."],
  "business": { "purpose": "string", "target_user": "string" },
  "roles_verified": ["string", "..."],
  "verified_flow": [
    { "step": "Login", "role": "admin", "applicable": true, "passed": true, "screenshot": "screenshots/admin-login.png", "description": "string" }
  ],
  "screenshots": [
    { "file": "screenshots/admin-dashboard-dark-mode.png", "page": "Dashboard", "role": "admin", "description": "string" }
  ],
  "security_checklist": { "secrets_exposed": false, "admin_auth_enforced": true, "verbose_errors": false, "cors_locked_down": true },
  "weaknesses": ["string", "..."],
  "missing_content": ["string", "..."],
  "outdated_content": ["string", "..."],
  "recommendations": ["string", "..."],
  "content_readiness": {
    "portfolio_page": true,
    "product_overview": true,
    "feature_highlights": true,
    "tech_summary": true,
    "case_study": false,
    "customer_success_story": false,
    "seo_content": true,
    "marketing_materials": true,
    "demo_script": true,
    "ai_handoff_doc": true
  }
}
```

## Field notes

- `role` on `verified_flow[]` and `screenshots[]` — omit the key entirely for single-role apps. Include it for every entry when the config declares multiple roles (see [Step 4](../SKILL.md#4-playwright-mcp-verification)). Never leave it blank/null when the app is multi-role — that loses which role a step was verified under.
- `roles_verified` — every role from config that Step 4 actually walked through. Used to confirm role coverage without scanning the whole `verified_flow` array.
- `security_checklist` — the 4 booleans from [Step 5 Technical](../SKILL.md#technical). See [Scoring Rubric](../SKILL.md#scoring-rubric) for how these convert to the "Security posture" score.
- `content_readiness` keys match the [Downstream Content Readiness](../SKILL.md#downstream-content-readiness) table rows exactly — never rename or add a key without updating that table too.

Keep `ai-handoff.json` and the `.md` files in sync — regenerate all of them from the same review pass, never patch one without the others.
