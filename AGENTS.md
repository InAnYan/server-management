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

> [!CAUTION]
> **PUBLIC REPOSITORY NOTICE**: This repository is public on GitHub. Absolutely **NO private information**—including server hostnames, actual node names, private IPs, domain names, usernames, or secrets—may ever be committed or published.

This repository is intended to be both a public Git repository and an active working directory for managing live servers. **Never leak secrets or private operational data into version control.**

### Private Operational Details (`PRIVATE.md`)

All machine-specific identifiers (such as target server hostnames, node names, internal IPs, and local SSH aliases) belong strictly in `PRIVATE.md` in the repository root.

- `PRIVATE.md` is strictly excluded by `.gitignore` and must **NEVER** be tracked or committed.
- Agents and operators should inspect local `PRIVATE.md` for actual server targets and node names, but must keep all tracked repository files completely sanitized and generic.

### Golden Rules for Agents

1. **Never commit plaintext secrets or private identifiers**: Passwords, API tokens, private SSH keys, TLS certificates, actual server hostnames, and node names must **NEVER** appear in tracked Git files or commit history.
2. **Respect `.gitignore`**:
   - `PRIVATE.md` (and `*.private.md`) is strictly ignored.
   - `secrets/` is strictly ignored.
   - `terraform/*/terraform.tfvars` (and any `*.tfvars`) is strictly ignored. Only create or update `*.tfvars.example` with sanitized placeholder values.
   - `ansible/inventory/hosts.ini` (and any `*.ini`) is strictly ignored. Use `hosts.ini.example` for documentation.
   - `.env` and `*.env` files are strictly ignored. Use `.env.example` for documentation.
   - `.vault_pass` and SSH private keys (`id_rsa`, `id_ed25519`) are strictly ignored.
3. **Ansible Secrets Policy**:
   - Plaintext Ansible secret variables reside locally in gitignored files (`ansible/group_vars/all/secrets.yml`). Never commit unencrypted secrets to Git.
4. **Environment Variables & OpenTofu**:
   - Credentials can be passed via environment variables (`PROXMOX_VE_API_TOKEN`, `PROXMOX_VE_ENDPOINT`) or via local untracked `terraform.tfvars`.
5. **Always inspect before committing**:
   - Run `git status` and `git diff --staged` before every commit to ensure no `.env`, `PRIVATE.md`, private keys, hostnames, or credentials are accidentally staged.

---

## 3. Directory Structure

```text
.
├── .env.example                       # Template for local environment variables
├── .gitignore                         # Strict exclusion of secrets, state, and caches
├── AGENTS.md                          # Agent rules and repository guidance
├── PRIVATE.md                         # Private operational details (gitignored)
├── README.md                          # Human-oriented overview and setup instructions
├── docs/                              # Project documentation
│   ├── decisions/                     # Architectural Decision Records (MADR)
│   ├── idea.md                        # High-level architecture overview
│   ├── naming.md                      # Naming conventions & machine ID allocations
│   ├── networking.md                  # Host networking and firewall architecture
│   ├── potential_security_issues.md   # Security notices
│   ├── security_rotation_plan.md      # Credential and key rotation guide
│   ├── server_setup.md                # Server bootstrap guide
│   └── vm_setup.md                    # VM lifecycle & base OS standards
├── secrets/                           # Local VM SSH keys & credentials (gitignored)
├── terraform/                         # Infrastructure provisioning (OpenTofu)
│   ├── server_setup/                  # Base Proxmox host setup & networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── core_infrastructure/          # Core infrastructure stack (DNS, proxy, git)
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
    │   └── hosts.ini.example          # Inventory template (hosts.ini is gitignored)
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

---

## 5. Deployment Workflow (Server-First Execution)

All live infrastructure commands and OpenTofu state reside exclusively on the target server in `/srv/admin`:

1. **Develop**: Edit configurations and documentation locally on your workstation.
2. **Verify**: Ensure pre-commit checks pass and no secrets or private data are staged.
3. **Push**: Push commits to GitHub (`git push origin main`).
4. **Deploy on the target server**:
   - Connect to the server via SSH (`ssh <server>` from `PRIVATE.md`).
   - Pull the latest commits: `cd /srv/admin && git pull origin main`.
   - Apply OpenTofu or Ansible changes on the server:

     ```bash
     cd /srv/admin/terraform/<stack>
     tofu plan
     tofu apply
     ```
