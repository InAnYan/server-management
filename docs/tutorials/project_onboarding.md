# Project Onboarding & GitOps Deployment Tutorial

This tutorial provides an operational guide for creating, provisioning, and deploying a new application workload within the infrastructure. It covers the full lifecycle from secret scoping in Infisical to automated GitOps delivery via Atlantis and Gitea Actions.

A living reference implementation of this workflow is maintained in [`apps/test-app/`](../../apps/test-app/).

## Overview of the Workflow

Deploying a new project follows a deterministic 6-phase pipeline:

1. **Secrets Management**: Scope secrets in Infisical and create Machine Identities.
2. **Repository Setup**: Create the Gitea repo, configure branch protection, and register the Atlantis webhook.
3. **Application Packaging**: Build container recipes with RAM-backed tmpfs secrets and port 80 host binding.
4. **Infrastructure as Code**: Declare VM provisioning in `opentofu/dev/` and `opentofu/prod/` with `atlantis.yaml`.
5. **Ansible Deployment & Routing**: Deploy container workloads, Caddy reverse proxy snippets, and Gatus health checks.
6. **CI/CD Automation**: Implement `.gitea/workflows/pr.yaml` (test/lint) and `.gitea/workflows/deploy.yaml` (build/push/deploy).

## Phase 1: Secrets Scoping in Infisical

Before writing application code or CI/CD pipelines, configure secrets in Infisical (`https://infisical.<domain>`):

### 1.1 Project & Environment Creation

1. Create a new project in Infisical named after your service (e.g. `analytics-api`).
2. Populate required runtime secrets under the `dev` and `prod` environments:
   - Database credentials: `POSTGRES_PASSWORD`, `POSTGRES_USER`, `POSTGRES_DB`
   - Application keys: `SECRET_KEY`, `API_TOKEN`

### 1.2 Universal Auth Machine Identities

Create dedicated Machine Identities with read-only access to the project:

1. Navigate to **Access Control** &rarr; **Machine Identities** in Infisical.
2. Create `cicd-runner`:
   - Authentication method: `Universal Auth`.
   - Role: Read-only access to `<app>` project secrets for `dev` and `prod`.
   - Generate a Client ID and Client Secret.
3. Save the Client ID and Client Secret securely for injection into Gitea Actions secrets.

## Phase 2: Repository Setup & Branch Governance in Gitea

### 2.1 Repository Creation

1. In Gitea (`https://git.<domain>`), create a new repository under the desired organization or user.
2. Clone locally and initialize with git.

### 2.2 Branch Protection Rules

Under repository **Settings** &rarr; **Branches**:

1. Protect `main` (Development branch):
   - Require status checks to pass before merging (`pr-validation`).
   - Require Pull Request review.
2. Protect `prod` (Production branch):
   - Restrict direct pushes to administrators.
   - Require Pull Request and approval.

### 2.3 Atlantis Webhook Registration

Under repository **Settings** &rarr; **Webhooks**:

1. Add a new Gitea webhook pointing to Atlantis:
   - Target URL: `http://10.10.1.12:4141/events` (internal Gitea-Atlantis routing)
   - HTTP Method: `POST`
   - Content Type: `application/json`
   - Trigger Events: `Push`, `Pull Request`, `Pull Request Comment`.

### 2.4 CI/CD Secrets Injection

Under repository **Settings** &rarr; **Actions** &rarr; **Secrets**:

1. Add `INFISICAL_CLIENT_ID`: The Universal Auth Client ID from Phase 1.
2. Add `INFISICAL_CLIENT_SECRET`: The Universal Auth Client Secret from Phase 1.

## Phase 3: Application Packaging & Container Standards

Workloads run containerized via Docker Compose. Adhere strictly to platform standards:

### 3.1 Host Port Binding

Containerized applications must always bind host port `80` mapped internally to the container port (e.g. `80:8000` or `80:80`):

```yaml
services:
  app:
    image: ${IMAGE_TAG}
    restart: unless-stopped
    ports:
      - "80:8000"
    secrets:
      - postgres_password
```

### 3.2 In-RAM Docker Compose File Secrets

Never store plaintext production credentials on disk or pass them as raw environment variables. Secrets must be mounted via Compose file secrets pointing to RAM-backed tmpfs (`/dev/shm`):

```yaml
secrets:
  postgres_password:
    file: /dev/shm/${APP_NAME}/postgres_password
```

Inside the container, the secret is accessible strictly in memory at `/run/secrets/postgres_password` (`mode 0400`).

## Phase 4: Infrastructure as Code (OpenTofu & Atlantis)

Application virtual machines are provisioned declaratively via OpenTofu and managed through Atlantis on Gitea PRs.

### 4.1 Sizing, Subnets & VMID Allocations

Refer to [Naming Conventions](../conventions/naming.md) and [Networking Architecture](../conventions/networking.md):

- **Development**:
  - VMID Range: `2000` – `2999` (e.g. `2100`)
  - Subnet / VNet: `vdev` (`10.21.0.0/16`, e.g. `10.21.1.10`)
  - Resource Pool: `dev_app`
- **Production**:
  - VMID Range: `3000` – `3999` (e.g. `3100`)
  - Subnet / VNet: `vprod` (`10.32.0.0/16`, e.g. `10.32.1.10`)
  - Resource Pool: `prod_app`

### 4.2 Declarative OpenTofu Configuration

Structure the repository with `opentofu/dev/` and `opentofu/prod/`. Each invokes the centralized VM module:

```hcl
module "app_vm" {
  source = "git::https://git.<domain>/infrastructure/server-management.git//opentofu/modules/vm"

  name         = "dev-app-<name>"
  node_name    = var.node_name
  vm_id        = 2100
  pool_id      = "dev-app"
  image_id     = var.image_id
  vnet_id      = "vdev"
  ipv4_address = "10.21.1.10/16"
  ipv4_gateway = "10.21.0.1"

  cores        = 2
  memory       = 2048
  disk_size    = 20

  ssh_public_keys = [var.ansible_public_key]

  firewall_rules = [
    {
      dport   = "80"
      comment = "Allow Caddy ingress HTTP"
    },
    {
      dport   = "22"
      comment = "Allow SSH automation"
    }
  ]
}
```

### 4.3 Atlantis Configuration (`atlantis.yaml`)

In the repository root, define the projects for automated planning:

```yaml
version: 3
automerge: false
projects:
  - name: dev
    dir: opentofu/dev
    autoplan:
      when_modified: ["opentofu/dev/*.tf"]
      enabled: true
  - name: prod
    dir: opentofu/prod
    autoplan:
      when_modified: ["opentofu/prod/*.tf"]
      enabled: true
```

## Phase 5: Ansible Deployment & Routing Integration

Post-merge application deployment is managed via a dedicated Ansible playbook (`ansible/deploy.yml`) containing three distinct plays:

### 5.1 Play 1: Target VM Deployment

Installs Docker, creates `/dev/shm/<app>/` with tmpfs secrets, logs into the Gitea container registry, synchronizes `docker-compose.yml`, runs `docker compose up -d`, and validates local container health (`http://127.0.0.1:80/healthz`).

### 5.2 Play 2: Ingress Routing (Caddy)

Templates a modular site definition to `/opt/caddy/conf.d/<app>-<env>.Caddyfile` on `core-coord-caddy` and reloads Caddy with zero downtime:

```caddyfile
{{ app_domain }} {
    tls internal
    reverse_proxy {{ target_vm_ip }}:80
}
```

### 5.3 Play 3: Health Monitoring (Gatus)

Registers the application's health check on `core-coord-gatus` according to the three-tier monitoring convention:

- **Development Workloads**: Add to `gatus_dev_endpoints` on `status-dev.<domain>` (SSO protected).
- **Production Workloads**: Add to `gatus_prod_endpoints` on `status.<domain>` (Public).

```yaml
- name: "<App Name> (<Env>)"
  group: "{{ 'Production Applications' if env == 'prod' else 'Development Applications' }}"
  url: "http://{{ target_vm_ip }}:80/healthz"
  interval: 30s
  conditions:
    - "[STATUS] == 200"
```

## Phase 6: CI/CD Delivery Pipelines (Gitea Actions)

### 6.1 Pull Request Verification (`.gitea/workflows/pr.yaml`)

Runs on all PRs targeting `main` and `prod`:

1. **Linting & Code Quality**: Executes `ruff check .` (or framework linter).
2. **Unit Tests**: Executes test suites (`pytest`).
3. **Dry-Run Container Build**: Builds the Docker container locally without pushing to verify build integrity.

### 6.2 GitOps Provisioning Flow

1. Opening the PR triggers Atlantis to run `tofu plan` for `dev` and comment the diff on the PR.
2. The operator reviews the proposed resources and comments:

   ```text
   atlantis apply -p dev
   ```

3. Atlantis applies the plan, provisions the VM on Proxmox, and comments confirmation.
4. The operator merges the PR into `main`.

### 6.3 Post-Merge Continuous Deployment (`.gitea/workflows/deploy.yaml`)

Runs automatically upon merge to `main` (for dev) or `prod` (for production):

1. **Infisical CLI Secret Retrieval**: Authenticates with `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` using `infisical export --format=dotenv-export`.
2. **Image Build & Tag**: Builds the multi-stage container tagged with the commit SHA and environment.
3. **Registry Push**: Pushes the image to Gitea Container Registry (`git.<domain>/<org>/<app>:<tag>`).
4. **Ansible Invocation**: Runs `ansible-playbook -i ansible/inventory/hosts.ini ansible/deploy.yml` with secrets passed in memory.
5. **Post-Deployment Verification**: Validates HTTP 200 response on `https://<app>.<domain>/healthz` and green status on Gatus.
