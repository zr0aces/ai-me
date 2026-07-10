---
name: saas-portfolio-review
description: Review one or more local SaaS applications and produce a verified, structured source-of-truth (docs + screenshots + metadata) that downstream AI agents can turn into portfolio pages, case studies, and marketing content. Uses Playwright MCP for live verification. Manual trigger only — invoke only when user explicitly runs /saas-portfolio-review or requests this skill by name.
trigger: /saas-portfolio-review
---

# SaaS Portfolio Review

## Purpose

Repeatable workflow for reviewing local SaaS applications and preparing portfolio-ready **source content**.

For each application, this skill:

- Reviews source code, documentation, and project structure.
- Starts and verifies the application using Docker.
- Uses Playwright MCP to navigate the application, validate key features, and capture screenshots.
- Reviews the product from **business, UX, UI, technical, and documentation** perspectives (see [Step 5](#5-product-review)).
- Collects only verified information; flags missing or outdated content instead of filling gaps with assumptions.
- Generates structured documentation and metadata reusable by downstream AI agents.
- Produces consistent source material for company websites, product portfolios, case studies, sales collateral, and marketing content.
- Supports reviewing one, multiple, or all applications defined in a local config file (see [Repository Selection](#repository-selection)), so the workflow is repeatable and scalable.

## Primary Goal

Produce a single source of truth per SaaS application — `ai-handoff.json` plus supporting docs and captioned screenshots — that lets a downstream AI agent generate, from verified content only:

- Product portfolio pages
- Product overviews
- Feature highlights
- Technology summaries
- Case studies
- Customer success stories
- SEO-friendly website content
- Marketing materials
- Demo scripts
- AI handoff documentation

This skill does not write the polished output itself — it collects and structures the evidence a downstream agent needs to write it without inventing facts. See [Downstream Content Readiness](#downstream-content-readiness) for what happens when evidence for one of these targets doesn't exist yet.

## Key Principles

- **Verify before documenting** — validate every feature/claim through the running application whenever possible (see [Step 4](#4-playwright-mcp-verification)).
- **Evidence-based content** — screenshots and repository documentation are the only supporting evidence; no claim without one.
- **Configuration-driven** — repos, URLs, credentials come from local config files, never hardcoded or typed inline (see [Configuration](#configuration)).
- **Repeatable and scalable** — same workflow for one repository or a full portfolio (see [Repository Selection](#repository-selection)).
- **AI-ready output** — structured, reusable content a downstream agent can transform without re-deriving it (see [Content Format](#content-format-ai-agent-readable)).
- **Maintain consistency** — unified tone, terminology, and section structure across every product reviewed in the same run.

## Agent Compatibility

This skill follows the portable Agent Skills format (YAML frontmatter + markdown body) and is not tied to any single AI agent vendor.

**Browser verification uses Playwright MCP** as configured in the calling agent (Claude Code, Codex, or any other MCP-capable agent — check the agent's MCP server config for a `playwright` entry). This is the required tool for Step 4, not an example among alternatives.

| Capability | Required tool |
|---|---|
| Browser automation | Playwright MCP (as configured in the agent) |
| Container orchestration | `docker compose`, `podman-compose`, or equivalent CLI |
| File read/write | Whatever native file tools the agent exposes |

If the calling agent has no Playwright MCP server configured, do not skip verification silently — follow the fallback in [Step 4](#4-playwright-mcp-verification).

---

# Configuration

Configuration is always read from a file. Never accept name, repo path, URLs, or credentials typed directly into the prompt as free text — a file path is the only valid input for these values, so secrets never land in chat history or logs.

## Config Source Resolution

Check in this order, first match wins:

1. **File path in the prompt.** If the user's prompt contains a file path (e.g. `/saas-portfolio-review ./configs/acme.yaml`, or "use the config at ./acme.yaml"), treat that file as the config source for this run instead of the default `portfolio.yaml`. Resolve the path relative to the current working directory. If the file doesn't exist, report the issue and stop — do not silently fall back to defaults.
2. **Default location.** Otherwise use `./portfolio.yaml` in the current working directory.

The config file's shape:

```yaml
workspace: /home/san/workspace

repositories:
  HausVis:
    path: /home/san/workspace/HausVis/
    application:
      url: https://dhvis.zerotrust.in.th/th/t/rp103/login
    credential_profile: hausvis
```

- `workspace` — base path repos resolve against when a repository's `path` is relative. If a repository's `path` is absolute, `workspace` is ignored for that entry.
- `repositories` — a map keyed by repository/product name (e.g. `HausVis`). The key **is** the name — there is no separate `name` field. Each entry supplies:
  - `path` — repository path, absolute or relative to `workspace`
  - `application.url` — application URL
  - `credential_profile` — name of a credential profile to resolve (see [Credentials](#credentials)); omit if the app needs no login
  - Docker Compose file path (optional key, e.g. `compose_file`, if it can't be inferred from `path`)
  - Available user roles (optional, when the app has more than one login role to verify)

A user-supplied config file may hold one repository entry or the full `repositories` map (same shape as `portfolio.yaml`).

## Credentials

Each repository entry references credentials by name via `credential_profile`, never inline. Resolve the profile by loading a credentials file and looking up that profile name, checking in this order (first match wins):

1. `./credentials.local.yaml` in the current working directory
2. `.ai/portfolio/credentials.local.yaml`

If both exist, use `./credentials.local.yaml` and note the conflict in the repository summary so the user can remove the stale file.

The credentials file is a map of profile name to credentials, e.g.:

```yaml
profiles:
  hausvis:
    username: ...
    password: ...
```

A profile may hold a single `username`/`password` pair, or nest credentials per role when a repository declares multiple roles. If a repository sets `credential_profile` but the named profile isn't found in either file, report the issue and skip that repository — do not fall back to guessed or empty credentials.

Never hardcode:

- Repository names
- URLs
- Ports
- Usernames
- Passwords

If configuration is missing, report the issue and skip that repository.

## Output Isolation

All generated output — for every repository — lives under `output/`, resolved relative to the **current working directory at the time the skill is run** (not the config file's location, and not the reviewed repository). **Never write generated review output into the reviewed repository itself.** The reviewed repo is read-only source material; the isolated output directory is the only place this skill writes to.

Each repository gets its own subdirectory, named from a slug of its `repositories` map key (lowercase, hyphens, e.g. `HausVis` → `hausvis`):

```
output/
├── portfolio-summary.md
├── acme-crm/
│   ├── portfolio.md
│   ├── repository-review.md
│   ├── content-review.md
│   ├── screenshots/
│   │   ├── index.md
│   │   └── *.png
│   └── ai-handoff.json
└── another-app/
    └── ...
```

If two repositories in the same config resolve to the same slug, report the conflict and stop before writing either — do not let one overwrite the other.

---

# Repository Selection

If the user specifies repository names:

Review only those repositories.

Otherwise:

Review every repository defined in the resolved config file (see [Config Source Resolution](#config-source-resolution)).

Repositories are processed **one at a time**.

Complete one repository before starting the next.

---

# Workflow

For each repository:

## 1. Load Configuration

Read repository settings from the resolved config file (see [Config Source Resolution](#config-source-resolution)).

Read credentials per [Credentials](#credentials).

Resolve:

- Repository name (the `repositories` map key)
- Repository path (absolute, or resolved against `workspace` if relative)
- Docker Compose file
- Application URL (`application.url`)
- Login credentials (via `credential_profile`, see [Credentials](#credentials))

---

## 2. Repository Review

Review:

- README.md
- docs/
- docker-compose.yml (or compose.yaml)
- Project structure

Identify:

- Product purpose
- Features
- Technology stack
- Architecture
- Modules

### Key Benefits

Separate from the feature list, extract **key benefits** — the outcome/value each feature delivers, not the feature itself. Pull only from what the docs actually claim; never infer a benefit the docs don't support.

- Feature → Benefit (e.g. "role-based access control" → "lets teams restrict sensitive data without extra tooling")
- Cap at 3-6 benefits. More than 6 means the summary isn't tight enough.
- Each benefit is one sentence, no marketing fluff, no unverifiable claims ("blazing fast" without a benchmark stays out).

If docs are too thin to support any benefit claim, say so explicitly in the repository summary rather than inventing one.

---

## 3. Application Verification

Start or verify containers using the configured container orchestration tool.

Wait until the application is healthy.

If startup fails:

- Capture logs
- Explain the issue
- Continue with the next repository

---

## 4. Playwright MCP Verification

Use Playwright MCP (see [Agent Compatibility](#agent-compatibility)).

Login using configured credentials.

Walk the application in this order. This sequence doubles as the **verified flow** downstream agents can turn into a demo script, so keep the order and record every step:

1. Login
2. Dashboard
3. Navigation
4. Major modules
5. CRUD pages
6. Reports
7. Settings
8. Notifications
9. Mobile layout
10. Dark mode

If the app defines multiple user roles, repeat steps 1-8 for each role that config declares (at minimum, confirm what differs — admin-only pages, restricted actions).

For each step, record a **verified flow entry**:

- Step name
- `role` (the role this step was verified under — required when config declares multiple roles, omitted entirely for single-role apps)
- `applicable` (false if the app doesn't have this — e.g. no dark mode — not a failure, not silently skipped)
- `passed` (only meaningful when applicable)
- Screenshot filename
- One-sentence description of what it demonstrates, tied back to a [key benefit](#key-benefits) where possible

Capture screenshots per entry. Filename convention:

- Single-role app: `kebab-case-page-state.png`, e.g. `dashboard-dark-mode.png`
- Multi-role app: `role-page-state.png`, e.g. `admin-dashboard-dark-mode.png` — the role prefix is required so the same page verified under two roles never collides on disk

Save to the repository's isolated output directory (see [Output Isolation](#output-isolation)):

```
output/<repo-slug>/screenshots/
```

**Fallback — Playwright MCP not configured:** Do not fabricate screenshots or verification results. Mark the repository's verification status as "unverified — Playwright MCP not configured", skip screenshot capture, and continue with steps 5-7 using only static repository review (README, docs, code structure). State this limitation explicitly in the repository summary and in `portfolio-summary.md`.

---

## 5. Product Review

Review the product from five perspectives. Every finding must trace back to something observed in Steps 2-4 (docs, code, or verified flow) — no perspective is a place to speculate.

### Business

- Product purpose and target user, from docs/marketing copy already in the repo — not invented
- Business value / problem solved
- Existing portfolio or marketing content already in the repo

### UX

- Navigation clarity, onboarding flow, error states seen during verification
- Friction points hit during the verified flow

### UI

- Visual polish, responsive layout, dark mode support (from Step 4 results)
- Consistency of design system/components

### Technical

- Technology stack, architecture, modules (from Step 2)
- Performance observations during verification (load times, obvious lag)
- Security checklist:
  - No secrets/API keys committed or exposed in served pages
  - Auth required on admin/sensitive routes (verified in Step 4, not assumed)
  - No verbose error pages exposing stack traces in the running app
  - CORS/API not wide open where it shouldn't be

### Documentation

- README/docs completeness (from Step 2)
- Missing or outdated content — call out anything docs claim that Step 4 could not verify

Suggest practical improvements per perspective.

---

## 6. Portfolio Generation

Generate or update, inside the repository's isolated output directory (see [Output Isolation](#output-isolation)):

```
output/<repo-slug>/
├── portfolio.md
├── repository-review.md
├── content-review.md
├── screenshots/
│   ├── index.md
│   └── *.png
└── ai-handoff.json
```

Update existing documents instead of replacing them.

### Content Format (AI-Agent Readable)

Every generated `.md` file must be parseable by another agent without re-running this skill or re-visiting the app. That means:

- Fixed heading structure, same section order every run — an agent grepping for a known heading must find it in the same place every time.
- Lead each section with a bullet list, not prose paragraphs. Prose is fine as elaboration *under* a bullet, never as the only content.
- No content requires the screenshot images themselves to be understood — every screenshot reference carries its caption inline as text, so an agent that can't render images still gets the point.
- Every generated `.md` file opens with a YAML front-matter block (`name`, `last_reviewed`) so an agent can parse identity without reading the body.

**`portfolio.md`** — the business/UX/marketing-facing summary. Fixed sections in this order: `## Key Benefits`, `## Features`, `## Screenshots`, `## Score`. Front-matter adds `overall_score`, `verified` (bool). `## Key Benefits` lists the benefits from [Step 2](#key-benefits) verbatim — this is the section a downstream agent should read first to summarize the product.

**`repository-review.md`** — the technical source doc. Fixed sections: `## Tech Stack`, `## Architecture`, `## Modules`, `## Performance Notes`, `## Security Checklist` (pass/fail per item from [Step 5 Technical](#technical)).

**`content-review.md`** — the documentation/content gap doc. Fixed sections: `## Existing Content` (pulled from [Step 5 Business](#business) — existing portfolio/marketing content already in the repo), `## Missing Content`, `## Outdated Content` (both pulled from [Step 5 Documentation](#documentation)), `## Recommendations` (pulled from [Step 7](#7-repository-summary)).

**`screenshots/index.md`** — a table, one row per screenshot: `| Screenshot | Page/State | Description |`, using the captions captured in [Step 4](#4-playwright-mcp-verification). No filename-only entries.

### Downstream Content Readiness

For each downstream content type listed in [Primary Goal](#primary-goal), record whether this review collected enough verified evidence to support it. Never mark a type "ready" on assumption.

| Content type | Ready when |
|---|---|
| Product portfolio page | Key benefits + features + ≥1 verified screenshot exist |
| Product overview | Business perspective notes exist |
| Feature highlights | ≥3 verified features with screenshot evidence |
| Technology summary | Tech stack identified in Step 2 |
| Case study | Real customer/usage data present in repo docs (never inferred) |
| Customer success story | Real testimonial/metric present in repo docs (never inferred) |
| SEO content | Key benefits + features exist (keywords derived only from verified text) |
| Marketing materials | Key benefits + ≥1 screenshot exist |
| Demo script | Core sequence (Login + Dashboard + ≥1 major module) all `applicable: true` and `passed: true` in the verified flow — one working screenshot alone doesn't qualify |
| AI handoff doc | Always ready — this is `ai-handoff.json` itself |

Case studies and customer success stories will almost always be "not ready" from a local repo review alone — that's expected, not a failure. Report it plainly rather than writing around the gap.

**`ai-handoff.json`** is the machine-primary artifact — any downstream agent should be able to read only this file and get the full picture. See `references/ai-handoff-schema.md` for the full schema (load it when writing this file — don't reconstruct the schema from memory).

---

## 7. Repository Summary

Provide:

- Overall score (see [Scoring Rubric](#scoring-rubric))
- Key benefits (see [Step 2](#key-benefits))
- Strengths
- Weaknesses
- Missing content
- Missing screenshots
- Downstream content readiness (see [Downstream Content Readiness](#downstream-content-readiness))
- Improvement recommendations

---

# Scoring Rubric

Score each repository 0-100, as the sum of five weighted dimensions. Record the per-dimension breakdown, not just the total, so scores are comparable across repositories and reruns.

| Dimension | Weight | 0 points | Full points |
|---|---|---|---|
| Functionality (verified) | 30 | Core flows broken or unverified | All verified flows work as documented |
| Documentation completeness | 20 | No README/docs | README + docs/ cover setup, features, architecture |
| UX/UI polish | 20 | Broken layout, no responsive/dark-mode support | Polished, responsive, dark-mode supported |
| Security posture | 15 | Hardcoded secrets, no auth on sensitive routes | No hardcoded secrets, auth enforced, no exposed admin routes |
| Portfolio readiness | 15 | No portfolio content, no screenshots | Portfolio docs + screenshots complete and current |

If a repository was verified via the [Step 4 fallback](#4-playwright-mcp-verification) (Playwright MCP not configured), cap "Functionality" at 15/30 and note in the summary that the score is based on static review only.

**Security posture formula:** `security score = (checks passed / 4) × 15`, rounded to the nearest integer, using the 4 booleans from the [Technical security checklist](#technical) / `security_checklist` in `ai-handoff.json`.

---

# Completion

After each repository:

Print:

- Repository name
- Status
- Overall score
- Next actions

After all repositories:

Generate, relative to the current working directory at the time the skill is run:

```
output/portfolio-summary.md
```

Include:

- Repositories reviewed
- Successes
- Failures
- Documentation gaps
- Missing screenshots
- Portfolio readiness
- Content readiness by type, aggregated across repositories (which apps are case-study-ready, demo-ready, etc.)
- Recommended priorities

---

# Rules

Always:

- Read configuration from local files.
- Use Playwright MCP for live verification when configured in the calling agent.
- Verify before documenting.
- Preserve existing documentation.
- Mask sensitive information.
- Generate accurate, structured source content that a downstream agent can turn into website-ready copy — not the final polished copy itself.
- Maintain consistent tone, terminology, and section structure across every repository reviewed in the same run.

Never:

- Hardcode repository information.
- Hardcode URLs.
- Hardcode credentials.
- Accept name, repo path, URLs, or credentials as inline prompt text — a config file path only.
- Write generated review output into the reviewed repository itself — always write to [the isolated output directory](#output-isolation).
- Invent features, benefits, or screenshots.
- Fabricate customer stories, testimonials, or case-study data — mark [content readiness](#downstream-content-readiness) false instead.
- Save a screenshot without its caption/description.
- Delete existing documentation.
- Report a verified score for a repository that used the Playwright-MCP-not-configured fallback.
