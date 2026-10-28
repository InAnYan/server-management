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

- **`opentofu/`**: Proxmox VM & LXC provisioning using the modern `bpg/proxmox` provider.
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
2. For OpenTofu, create your local variables file:
   ```bash
   cp opentofu/terraform.tfvars.example opentofu/terraform.tfvars
   # Edit opentofu/terraform.tfvars with your Proxmox API token and endpoint
   ```
3. For Ansible Vault, create a vault password file (or pass `--ask-vault-pass`):
   ```bash
   echo "your-strong-vault-password" > .vault_pass
   chmod 600 .vault_pass
   ```
   To create an encrypted secrets file:
   ```bash
   ansible-vault create ansible/group_vars/all/vault.yml --vault-password-file .vault_pass
   ```

### 3. Usage

#### OpenTofu (Provisioning)
```bash
cd opentofu
tofu init
tofu plan
tofu apply
```

#### Ansible (Configuration)
```bash
cd ansible
# Test connectivity
ansible all -m ping

# Run base configuration
ansible-playbook site.yml --vault-password-file ../.vault_pass
```

---

## Contributing & Automation

AI agents and automated tools should refer to [AGENTS.md](AGENTS.md) for strict operational constraints and repository guidelines.
