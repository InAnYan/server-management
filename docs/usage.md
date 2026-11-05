# Infrastructure Usage & Operations Guide

This guide covers day-to-day operations, maintenance tasks, and management commands executed via Ansible from the server administration workspace (`/srv/admin/ansible`).

## General Playbook Execution

All operational commands are executed using the public inventory file:

```bash
cd /srv/admin/ansible
```

### Full Configuration Run

To apply and converge the entire infrastructure stack:

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

### Dry-Run & Diff Mode

To preview configuration changes without applying them:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --check --diff
```

### Limiting Execution to Specific Hosts or Groups

Use the `-l` (`--limit`) flag to target specific tiers, groups, or nodes:

```bash
# Target only core coordinator nodes
ansible-playbook -i inventory/hosts.ini site.yml -l core_coordinators

# Target only database nodes across all environments
ansible-playbook -i inventory/hosts.ini site.yml -l core_databases:dev_databases:prod_databases

# Target a single virtual machine
ansible-playbook -i inventory/hosts.ini site.yml -l core-coord-gitea
```

## Tag-Based Targeted Execution

Use `--tags` to execute specific functional roles without running the full playbook:

| Tag | Target Roles / Tasks | Description |
| :--- | :--- | :--- |
| `bootstrap` | `bootstrap` | Auto-generates missing SSH keypairs and persistent credentials in `/srv/secrets/` |
| `common` | `common` | Baseline OS packages, timezone, users (`ansible`, `admin`), SSH hardening, timesync |
| `users` | `common` (users task) | Provisions and synchronizes the interactive `admin` operator account |
| `docker` | `docker` | Installs or updates Docker CE runtime and Compose plugin |
| `postgres` | `postgres` | Deploys PostgreSQL containers, admin passwords, probe roles, and Gitea database |
| `technitium` | `technitium` | Configures Technitium DNS server, primary zones, and A-records via API |
| `uptimekuma` | `uptimekuma` | Deploys Uptime Kuma monitoring, service probe groups, and public status page |
| `gitea` | `gitea` | Configures Gitea Git platform and administrator account |
| `caddy` | `caddy` | Templates modular site definitions in `/opt/caddy/conf.d/` and reloads Caddy |
| `host_port_forward` | `host_port_forward` | Sets up systemd socket activation on Proxmox host (DNS 53, Git SSH 2222) |
| `redis` | `redis` | Deploys Valkey / Redis in-memory cache and key-value store with password protection |
| `minio` | `minio` | Deploys MinIO S3 object storage server and local `mc` client wrapper |

Examples:

```bash
# Re-apply only Caddy reverse proxy routing
ansible-playbook -i inventory/hosts.ini site.yml --tags caddy

# Re-apply common baseline configuration across all nodes
ansible-playbook -i inventory/hosts.ini site.yml --tags common

# Re-configure DNS records and reverse proxy ingress
ansible-playbook -i inventory/hosts.ini site.yml --tags technitium,caddy
```

## Operational Playbooks (`playbooks/ops/`)

Dedicated operational playbooks in `playbooks/ops/` handle routine administration tasks:

### 1. Connectivity & Node Health Check (`ping.yml`)

Verify SSH connectivity and Python execution across all nodes:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/ops/ping.yml
```

### 2. Provision Additional Administrator Accounts (`create_admin_user.yml`)

<!-- [oman->req~app-accounts-ansible~1] -->
Create administrator accounts on Technitium DNS, Uptime Kuma, or Gitea without modifying configuration files:

```bash
# Provision on both Technitium and Uptime Kuma simultaneously
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "username=newadmin" \
  -e "password=NewSecretPassword123!"

# Provision only on Technitium DNS (with optional display name)
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=technitium" \
  -e "username=dnsadmin" \
  -e "password=NewSecretPassword123!" \
  -e "display_name='DNS Admin'"

# Provision only on Uptime Kuma
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=uptimekuma" \
  -e "username=kumaadmin" \
  -e "password=NewSecretPassword123!"

# Provision administrator on Gitea
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=gitea" \
  -e "username=gitadmin" \
  -e "email=gitadmin@example.com" \
  -e "password=NewSecretPassword123!"
```

### 3. Provision Gitea Users (`create_gitea_user.yml`)

Provision regular developer accounts or team administrators in Gitea:

```bash
# Standard user (non-admin)
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_gitea_user.yml \
  -e "username=developer" \
  -e "email=dev@example.com" \
  -e "password=DevPassword123!" \
  -e "is_admin=false"

# Administrator user
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_gitea_user.yml \
  -e "username=lead" \
  -e "email=lead@example.com" \
  -e "password=LeadPassword123!" \
  -e "is_admin=true"
```

### 4. Provision Bucket-Restricted MinIO S3 Users (`create_minio_user.yml`)

<!-- [oman->req~app-accounts-ansible~1] -->
Create application or service accounts on MinIO restricted strictly to a single S3 bucket:

```bash
# Create bucket and provision user restricted strictly to 'backups' bucket on core MinIO
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_minio_user.yml \
  -e "username=backupagent" \
  -e "password=SecretBackupPassword123!" \
  -e "bucket=backups"

# Provision user restricted to 'app-assets' bucket on dev MinIO
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_minio_user.yml \
  -e "target_host=dev-data-minio" \
  -e "username=appdev" \
  -e "password=AppSecretPassword123!" \
  -e "bucket=app-assets"
```

### 5. Ingress-Isolated Password Rotation (`rotate_admin_passwords.yml`)

Rotate administrative passwords with automated ingress isolation (Caddy temporarily serves HTTP 503 while database, Technitium, and Uptime Kuma credentials rotate):

```bash
ansible-playbook -i inventory/hosts.ini playbooks/ops/rotate_admin_passwords.yml
```

### 6. Docker Compose Service Control (`compose.yml`)

Restart, stop, or pull containerized services on target nodes:

```bash
# Restart a service container
ansible-playbook -i inventory/hosts.ini playbooks/ops/compose.yml \
  -e "host=core-coord-caddy" \
  -e "service=caddy" \
  -e "action=restart"

# Pull latest images and recreate container
ansible-playbook -i inventory/hosts.ini playbooks/ops/compose.yml \
  -e "host=core-coord-gitea" \
  -e "service=gitea" \
  -e "action=pull"
```

### 7. Inspect System & Service Logs (`system-logs.yml`)

Fetch recent systemd journal logs from target nodes:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/ops/system-logs.yml -l core-coord-caddy
```

### 8. Safe Node Reboot (`reboot.yml`)

Gracefully reboot a virtual machine:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/ops/reboot.yml -l dev-data-postgres
```

## Ad-Hoc Reverse Proxy Route Injection

<!-- [oman->req~reverse-proxy-ansible~1] -->
Add a new public ingress route to Caddy dynamically from the command line without modifying configuration files:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --tags caddy \
  -e "{'caddy_site': {'name': 'myapp', 'ip': '10.21.0.15', 'port': 8080, 'domain': 'app.example.com'}}"
```

## Optional Workloads & Feature Flags

Workloads such as the Technitium DNS server, Valkey / Redis in-memory caches, and MinIO S3 object storage can be toggled on or off independently across environments via feature flags in OpenTofu and Ansible. When disabled, VMs are not provisioned (or deleted if already running), and Ansible excludes them from execution without SSH connection errors.

### Toggling In-Memory Cache (Valkey / Redis)

Valkey / Redis can be toggled independently for `core`, `dev`, and `prod`:

1. **OpenTofu (`terraform.tfvars`)**:

   ```hcl
   enable_redis_core = true
   enable_redis_dev  = true
   enable_redis_prod = false
   ```

2. **Ansible (`ansible/group_vars/all/main.yml`)**:

   ```yaml
   enable_redis_core: true
   enable_redis_dev: true
   enable_redis_prod: false
   ```

### Toggling S3 Object Storage (MinIO)

MinIO S3 storage can be enabled on `core`, `dev`, or `prod`:

1. **OpenTofu (`terraform.tfvars`)**:

   ```hcl
   enable_minio_core = true
   enable_minio_dev  = false
   enable_minio_prod = false
   ```

2. **Ansible (`ansible/group_vars/all/main.yml`)**:

   ```yaml
   enable_minio_core: true
   enable_minio_dev: false
   enable_minio_prod: false
   ```

When `enable_minio_core` is enabled, Caddy automatically provisions ingress routes for `s3.<domain>` (API) and `s3-console.<domain>` (Web Console).

### Toggling Technitium DNS

1. **OpenTofu (`terraform.tfvars`)**: `enable_technitium = false` (or `true`).
2. **Ansible (`ansible/group_vars/all/main.yml`)**: `enable_technitium: false` (or `true`). Automatically tears down host port forwarding for port 53 and purges reverse proxy routes.

## Relevant Documentation

- [Server Setup Guide](setup.md): Host bootstrap and initial deployment runbook.
- [Infrastructure Architecture & Core Ideas](idea.md): Conceptual design and environment taxonomy.
- [Secrets Rotation Plan](security/secrets_rotation_plan.md): In-depth security and credential lifecycle procedures.
