# File Templates

Exact bodies to copy when [SKILL.md](../SKILL.md) says to create one of these files. Load this file only when actually writing one of them — don't read it just to plan.

## GitHub Templates (§9)

### `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
### Current Behavior
### Expected Behavior
### Steps to Reproduce
### Environment
### Logs
```

### `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
### Problem
### Proposed Solution
### Alternatives
### Additional Context
```

### `.github/pull_request_template.md`

```markdown
## Summary
## Changes
## Testing
## Screenshots
```

## Deployment Example Files (§10)

All live in `docs/deployment/`. Add only when SKILL.md's decision table says the app actually uses that technology — never speculatively.

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

Reference these from `docs/deployment.md`:
```markdown
See `docs/deployment/` for example configs. Copy and adapt before use:
- `docs/deployment/.env.example` → `.env`
- `docs/deployment/docker-compose.yml.example` → `docker-compose.yml`
- `docs/deployment/nginx.conf.example` → `/etc/nginx/conf.d/app.conf`
```

## AI-Friendly Files (§11)

### `.github/instructions.md`

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

### `docs/coding-standards.md`

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
