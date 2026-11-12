# Test App — Template Service

Reference web application template designed for automated CI/CD and GitOps delivery on Proxmox VE via Gitea Actions and Atlantis.

## Technology Stack

- **Runtime**: Python 3.11+
- **Framework**: FastAPI + Uvicorn
- **Package & Dependency Manager**: `uv`
- **Containerization**: Multi-stage Docker image & Docker Compose
- **Orchestration**: OpenTofu (Atlantis) & Ansible

## Local Development

```bash
# Install dependencies
uv sync --extra dev

# Run linters
uv run ruff check .

# Run test suite
uv run pytest

# Start local development server
uv run uvicorn src.main:app --reload --port 8000
```

## Deployment & Delivery Architecture

Continuous deployment is orchestrated via Ansible in [`ansible/deploy.yml`](ansible/deploy.yml):

1. **Target VM Deployment**: Authenticates against the Gitea container registry, synchronizes `docker-compose.yml`, runs `docker compose up -d`, and validates local health.
2. **Caddy Ingress Routing**: Deploys a modular site snippet to `/opt/caddy/conf.d/test-app-<env>.Caddyfile` on `core-coord-caddy` and reloads Caddy without downtime.
3. **Gatus Health Monitoring**: Registers or updates the HTTP health check endpoint on `core-coord-gatus` in `/opt/gatus/config/config.yaml` under the `Applications` group.
