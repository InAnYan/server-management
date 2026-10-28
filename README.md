# Server Management Infrastructure

Bare-bones infrastructure repository for managing Proxmox VE servers, virtual machines, and containers using **OpenTofu** (provisioning) and **Ansible** (configuration management).

---

## Architecture Overview

```text
               ┌────────────────┐
               │    Operator    │
               └───────┬────────┘
                       │
         ┌─────────────┴─────────────┐
         ▼                           ▼
 ┌───────────────┐           ┌───────────────┐
 │   OpenTofu    │           │    Ansible    │
 │ (Provisioning)│           │(Configuration)│
 └───────┬───────┘           └───────┬───────┘
         │                           │
         ▼                           ▼
 ┌───────────────────────────────────────────┐
 │                Proxmox VE                 │
 │            (VMs / LXCs / Host)            │
 └───────────────────────────────────────────┘
```

- **`opentofu/vms/`** (or `terraform/vms/`): Generic Proxmox VM management.
- **`opentofu/uptime-kuma/`** (or `terraform/uptime-kuma/`): Dedicated stack for Uptime Kuma monitoring service.
- **`ansible/`**: Base configuration, package installations, and system hardening.

---

## Secrets Management Strategy

Secrets (`*.tfvars`, `.env`, and `ansible/**/secrets.yml`) are stored **locally in plaintext** for operational simplicity and are **strictly forbidden from being committed to Git**.

Protection is enforced by multiple defensive layers:

- **Git Exclusion**: `.gitignore` blocks `.env`, `*.tfvars`, `*.tfstate`, `secrets.yml`, and private keys. Only `.example` templates are tracked.
- **Git Pre-commit Hook**: Automatically scans staged files and content before any commit can be created.
- **CI/CD Pipelines**: GitHub Actions and GitLab CI fail if any secrets or sensitive file patterns are detected.
- **Security Assessment**: See [docs/potential_security_issues.md](docs/potential_security_issues.md) for an analysis of risks and safeguards.

| Secret Type | Local File (Gitignored) | Tracked Template |
| :--- | :--- | :--- |
| **Proxmox API Credentials** | `terraform/*/terraform.tfvars`, `.env` | `terraform/*/terraform.tfvars.example`, `.env.example` |
| **Ansible Passwords & Keys** | `ansible/group_vars/all/secrets.yml` | `ansible/group_vars/all/secrets.yml.example` |
| **SSH Private Keys** | `~/.ssh/` | Never stored in repository |

---

## Getting Started

### 1. Prerequisites

- **Git**
- **OpenTofu** (`>= 1.6`)
- **Ansible** (`>= 2.15`)
- Proxmox VE 7.x/8.x with an API token generated (`PVEAPIToken`)

### 2. Configure Secrets & Environment

1. Copy the environment template:

   ```bash
   cp .env.example .env
   ```

2. For OpenTofu / Terraform stacks, create your local variables:

   ```bash
   # For VMs stack
   cp opentofu/vms/terraform.tfvars.example opentofu/vms/terraform.tfvars
   
   # For Uptime Kuma stack
   cp opentofu/uptime-kuma/terraform.tfvars.example opentofu/uptime-kuma/terraform.tfvars
   ```

3. For Ansible secrets (local plaintext, gitignored):

   ```bash
   cp ansible/group_vars/all/secrets.yml.example ansible/group_vars/all/secrets.yml
   # Edit ansible/group_vars/all/secrets.yml with your actual server passwords / keys
   ```

4. Enable Git pre-commit hook:

   ```bash
   git config core.hooksPath .githooks
   ```

### 3. Usage

#### Provisioning (OpenTofu / Terraform)

```bash
# Provision generic VMs:
cd opentofu/vms          # or: cd terraform/vms
tofu init
tofu plan
tofu apply

# Provision Uptime Kuma:
cd opentofu/uptime-kuma  # or: cd terraform/uptime-kuma
tofu init
tofu plan
tofu apply
```

#### Ansible (Configuration)

Run playbooks using local secrets (auto-loaded from `ansible/group_vars/all/secrets.yml`):

```bash
cd ansible
# Test connectivity
ansible all -m ping

# Run base configuration playbook
ansible-playbook site.yml
```

---

## Contributing & Automation

AI agents and automated tools should refer to [AGENTS.md](AGENTS.md) for strict operational constraints and repository guidelines.
