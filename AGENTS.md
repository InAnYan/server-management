# AGENTS.md — Guidelines for AI Agents & Automation

This document provides instructions, constraints, and conventions for AI agents operating in this repository.

---

## 1. Project Overview & Role

This repository manages infrastructure and configuration for a Proxmox VE environment:

- **Provisioning layer (`terraform/`)**: Manages Proxmox host setup, VMs, LXC containers, networks, and storage using OpenTofu (`bpg/proxmox` provider).
- **Configuration layer (`ansible/`)**: Configures operating systems, packages, users, and services on provisioned nodes.

> [!IMPORTANT]
> **Tooling & Naming Convention**: Always use `terraform/` folder naming in all paths, documentation, and agent reasoning. Internally, always execute commands using OpenTofu (`tofu init`, `tofu plan`, `tofu apply`).

---

## 2. Secrets Management & Safety Policy (CRITICAL)

This repository is intended to be both a Git repository and an active working directory for managing live servers. **Never leak secrets into version control.**

### Golden Rules for Agents

1. **Never commit plaintext secrets**: Passwords, API tokens, private SSH keys, TLS certificates, and decryption keys must **NEVER** appear in tracked Git files or commit history.
2. **Respect `.gitignore`**:
   - `terraform/*/terraform.tfvars` (and any `*.tfvars`) is strictly ignored. Only create or update `*.tfvars.example` with sanitized placeholder values.
   - `.env` and `*.env` files are strictly ignored. Use `.env.example` for documentation.
   - `.vault_pass` and SSH private keys (`id_rsa`, `id_ed25519`) are strictly ignored.
3. **Ansible Secrets Policy**:
   - Plaintext Ansible secret variables reside locally in gitignored files (`ansible/group_vars/all/secrets.yml`). Never commit unencrypted secrets to Git.
4. **Environment Variables & OpenTofu**:
   - Credentials can be passed via environment variables (`PROXMOX_VE_API_TOKEN`, `PROXMOX_VE_ENDPOINT`) or via local untracked `terraform.tfvars`.
5. **Always inspect before committing**:
   - Run `git status` and `git diff --staged` before every commit to ensure no `.env`, private keys, or credentials are accidentally staged.

---

## 3. Directory Structure

```text
.
├── .env.example                       # Template for local environment variables
├── .gitignore                         # Strict exclusion of secrets, state, and caches
├── AGENTS.md                          # Agent rules and repository guidance
├── README.md                          # Human-oriented overview and setup instructions
├── docs/                              # Project documentation
│   ├── potential_security_issues.md   # Security notices
│   └── server_setup.md                # Server bootstrap guide
├── terraform/                         # Infrastructure provisioning (OpenTofu)
│   ├── server_setup/                  # Base Proxmox host setup & networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── vms/                           # VM stack
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── uptime-kuma/                   # Uptime Kuma stack
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
├── opentofu -> terraform              # Symlink for opentofu CLI compatibility
└── ansible/                           # Server configuration & state
    ├── ansible.cfg                    # Ansible configuration
    ├── inventory/
    │   └── hosts.ini                  # Inventory definition
    ├── group_vars/                    # Group-level variables
    │   └── all/
    │       └── vault.yml.example      # Example encrypted variable structure
    └── site.yml                       # Primary playbook entrypoint
```

---

## 4. Operational Best Practices

1. **Idempotence**:
   - All Ansible tasks and playbooks must be idempotent.
   - Use declarative Ansible modules (`ansible.builtin.apt`, `ansible.builtin.template`, `ansible.builtin.systemd`) rather than raw `command` or `shell` where possible.
2. **Review Before Apply**:
   - Always run `tofu plan` before applying infrastructure changes.
   - For Ansible, support `--check` / `--diff` runs where applicable.
3. **Keep Changes Minimal**:
   - Make small, focused edits. Do not refactor unrelated playbooks or configurations.
   - Preserve comments, structure, and existing formatting.
