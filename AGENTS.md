# AGENTS.md — Guidelines for AI Agents & Automation

This document provides instructions, constraints, and conventions for AI agents operating in this repository.

---

## 1. Project Overview & Role

This repository manages infrastructure and configuration for a Proxmox VE environment:

- **Provisioning layer (`opentofu/`)**: Manages Proxmox VMs, LXC containers, networks, and storage using OpenTofu (`bpg/proxmox` provider).
- **Configuration layer (`ansible/`)**: Configures operating systems, packages, users, and services on provisioned nodes.

---

## 2. Secrets Management & Safety Policy (CRITICAL)

This repository is intended to be both a Git repository and an active working directory for managing live servers. **Never leak secrets into version control.**

### Golden Rules for Agents

1. **Never commit plaintext secrets**: Passwords, API tokens, private SSH keys, TLS certificates, and decryption keys must **NEVER** appear in tracked Git files or commit history.
2. **Respect `.gitignore`**:
   - `opentofu/terraform.tfvars` (and any `*.tfvars`) is strictly ignored. Only create or update `*.tfvars.example` with sanitized placeholder values.
   - `.env` and `*.env` files are strictly ignored. Use `.env.example` for documentation.
   - `.vault_pass` and SSH private keys (`id_rsa`, `id_ed25519`) are strictly ignored.
3. **Ansible Vault for encrypted repo secrets**:
   - When secrets must be version-controlled for Ansible (e.g., in `group_vars` or `host_vars`), they **must** be encrypted using `ansible-vault` (e.g. `ansible-vault encrypt ...`).
   - The vault password file (`.vault_pass`) resides in the repository root or `~/.vault_pass` and is gitignored.
4. **Environment Variables for OpenTofu**:
   - OpenTofu credentials can be passed via environment variables (`PROXMOX_VE_API_TOKEN`, `PROXMOX_VE_ENDPOINT`) or via a local untracked `terraform.tfvars`.
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
├── opentofu/                          # Infrastructure provisioning (Proxmox; aliased as terraform/)
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
├── terraform -> opentofu              # Symlink for terraform CLI users
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
