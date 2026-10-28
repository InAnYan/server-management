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

Because this directory serves as both a **Git repository** (potentially pushed to remote) and an **active server management workspace**, secrets are handled with a multi-layered approach:

| Secret Type | Storage Location | Protection Mechanism |
| :--- | :--- | :--- |
| **Proxmox API Credentials** | `opentofu/terraform.tfvars` or `.env` | Strict `.gitignore` rule; committed `*.example` files only |
| **Ansible Secrets & Passwords** | `ansible/group_vars/**/vault.yml` | Encrypted via **Ansible Vault** (`ansible-vault encrypt`) |
| **Vault Master Password** | `.vault_pass` or `~/.vault_pass` | Strict `.gitignore` rule |
| **SSH Private Keys** | `~/.ssh/` | Never stored in repository tree; standard SSH agent or paths |

> [!IMPORTANT]
> The `.gitignore` is pre-configured to ignore all `.env` files, `*.tfvars`, `*.tfstate`, `.vault_pass`, and SSH private keys. Always verify staged changes with `git status` before committing.

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
3. For Ansible Vault (Approach 1: Full-file encryption):
   ```bash
   # Create your local vault password file (gitignored)
   echo "your-strong-vault-password" > .vault_pass
   chmod 600 .vault_pass

   # Create the encrypted secrets file
   ansible-vault create ansible/group_vars/all/vault.yml
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
Because `ansible.cfg` is pre-configured with `vault_password_file = ../.vault_pass`, Ansible automatically decrypts `vault.yml`:
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
