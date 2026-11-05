# AGENTS.md — Guidelines for AI Agents & Automation

This document provides instructions, constraints, and conventions for AI agents operating in this repository.

## 1. Project Overview & Role

This repository manages infrastructure and configuration for a Proxmox VE environment:

- **Provisioning layer (`opentofu/`)**: Manages Proxmox host setup, VMs, networks, and storage using OpenTofu (`bpg/proxmox` provider).
- **Configuration layer (`ansible/`)**: Configures operating systems, packages, users, and services on provisioned nodes.

> [!IMPORTANT]
> **Target Audience**: This repository and its documentation are intended for experienced operators who already know how to administer Unix systems. Documentation must be concise and avoid basic tutorials, generic OS explanations, and beginner handholding.

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
   - `opentofu/*/terraform.tfvars` (and any `*.tfvars`) is strictly ignored. Only create or update `*.tfvars.example` with sanitized placeholder values.
   - `ansible/inventory/*.private.ini` is strictly ignored. `ansible/inventory/hosts.ini` is tracked and uses `localhost` (`ansible_connection=local`) and internal subnet IPs.
   - `.env` and `*.env` files are strictly ignored. Use `.env.example` for documentation.
   - `.vault_pass` and SSH private keys (`id_rsa`, `id_ed25519`) are strictly ignored.
3. **Ansible Secrets Policy**:
   - Plaintext Ansible secret variables reside locally in gitignored files (`ansible/group_vars/all/secrets.yml`). Never commit unencrypted secrets to Git.
4. **Environment Variables & OpenTofu**:
   - Credentials can be passed via environment variables (`PROXMOX_VE_API_TOKEN`, `PROXMOX_VE_ENDPOINT`) or via local untracked `terraform.tfvars`.
5. **Always inspect before committing**:
   - Run `git status` and `git diff --staged` before every commit to ensure no `.env`, `PRIVATE.md`, private keys, hostnames, or credentials are accidentally staged.

## 3. Directory Structure

```text
.
├── .env.example                       # Template for local environment variables
├── .gitea/workflows/                  # Gitea Actions CI/CD workflows
├── .github/workflows/                 # GitHub Actions CI/CD workflows
├── .gitignore                         # Strict exclusion of secrets, state, and caches
├── .gitlab-ci.yml                     # GitLab CI configuration
├── AGENTS.md                          # Agent rules and repository guidance
├── PRIVATE.md                         # Private operational details (gitignored)
├── README.md                          # Human-oriented overview and setup instructions
├── docs/                              # Project documentation
│   ├── README.md                      # Central documentation index
│   ├── idea.md                        # High-level architecture & core ideas
│   ├── requirements.md                # System features & requirements (OpenFastTrace)
│   ├── setup.md                       # Server bootstrap & deployment guide
│   ├── usage.md                       # Operations & Ansible commands guide
│   ├── conventions/                   # Structural conventions
│   │   ├── README.md                  # Conventions index
│   │   ├── naming.md                  # Naming conventions & machine ID allocations
│   │   ├── networking.md              # Host networking and firewall architecture
│   │   ├── permissions.md             # Operational boundaries & resource pool permissions
│   │   └── requirements.md            # OFT traceability conventions & item syntax
│   ├── decisions/                     # Architectural Decision Records (MADR)
│   │   ├── README.md                  # Decisions index
│   │   └── 0000-*.md                  # Individual decision records
│   ├── implementation/                # Technical implementation guides
│   │   ├── README.md                  # Implementation index
│   │   └── vm_setup.md                # VM lifecycle & base OS standards
│   └── security/                      # Security documentation
│       ├── README.md                  # Security index
│       ├── potential_security_issues.md # Security notices & concentration risks
│       ├── secrets_management.md      # Secrets management policy & defense-in-depth
│       └── secrets_rotation_plan.md   # Credential and key rotation guide
├── secrets/                           # Local VM SSH keys & credentials (gitignored)
├── opentofu/                          # Infrastructure provisioning (OpenTofu)
│   ├── main.tf                        # Proxmox provider, node firewall, cluster firewall, pools
│   ├── networks.tf                    # SDN simple zone, vnets, subnets, sdn_applier
│   ├── images.tf                      # Debian cloud image download
│   ├── vms.tf                         # Virtual machine workload entrypoint calling vms/ module
│   ├── backups.tf                     # Pool backup jobs
│   ├── moved.tf                       # State migration blocks for refactored VM modules
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── modules/                       # Reusable OpenTofu modules
│   │   └── vm/                        # Unified VM definition and VM firewall rules module
│   └── vms/                           # Workload VM definitions (caddy, technitium, gitea, postgres, redis, minio)
│       ├── main.tf                    # Provider configuration
│       ├── variables.tf               # Workload variables
│       ├── outputs.tf                 # Workload outputs
│       ├── caddy.tf                   # VM declaration, firewall rules, backup job
│       ├── uptimekuma.tf              # VM declaration, firewall rules, backup job
│       ├── gitea.tf                   # VM declaration, firewall rules, backup job
│       ├── technitium.tf              # VM declaration, firewall rules, backup job (feature-flagged)
│       ├── postgres_core.tf           # VM declaration, firewall rules
│       ├── postgres_dev.tf            # VM declaration, firewall rules
│       └── postgres_prod.tf           # VM declaration, firewall rules
├── terraform -> opentofu              # Symlink for legacy tool compatibility
└── ansible/                           # Server configuration & state
    ├── ansible.cfg                    # Ansible configuration
    ├── inventory/
    │   └── hosts.ini                  # Infrastructure inventory (localhost & internal SDN IPs)
    ├── group_vars/                    # Group-level variables
    │   ├── all/                       # Global variables and feature flags
    │   └── *.yml                      # Tier-specific variable definitions
    ├── playbooks/
    │   ├── bootstrap.yml              # Host bootstrap playbook
    │   └── ops/                       # Operational task playbooks (accounts, rotation, logs, compose)
    ├── roles/                         # Modular configuration roles
    └── site.yml                       # Primary playbook entrypoint
```

## 4. Operational Best Practices

1. **Idempotence**:
   - All Ansible tasks and playbooks must be idempotent.
   - Use declarative Ansible modules (`ansible.builtin.apt`, `ansible.builtin.template`, `ansible.builtin.systemd`) rather than raw `command` or `shell` where possible.
2. **Review Before Apply**:
   - Always run `tofu plan` before applying infrastructure changes.
   - For Ansible, support `--check` / `--diff` runs where applicable.
3. **Keep Changes Minimal**:
   - Make small, focused edits. Do not refactor unrelated playbooks or configurations.
   - Preserve structure and formatting.
4. **Code Comments**:
   - Write comments only for non-trivial logic, subtle workarounds, or essential context.
   - Do not write comments that merely repeat or describe what the code or configuration already declares.
5. **Documentation DRY (Don't Repeat Yourself)**:
   - Do not duplicate text across documentation files.
   - If a concept, setting, or specification is already documented in another file, link directly to the relevant document and section.
6. **No Markdown Dividers**:
   - Do not use horizontal rule dividers (`---`) in markdown documentation. Use headings to structure content.
7. **Requirements Traceability (OpenFastTrace)**:
   - All architectural requirements and system features are tracked via OpenFastTrace (OFT) in `docs/requirements.md`.
   - Maintain the standard trace hierarchy: `feat` (broad feature) &rarr; `req` (concrete specification) &rarr; `impl` (code tag) / `oman` (operational manual tag).
   - Any modification or addition to infrastructure features must include corresponding requirement updates and tags (`[impl->...]` in code, `<!-- [oman->...] -->` in docs).
   - Verify trace coverage before committing: `oft trace -v all .` (must report zero defects).
8. **Feature Flags for Optional Services**:
   - Optional service VMs (e.g. Technitium DNS) must be toggleable via boolean feature flags (`enable_<service>`).
   - In OpenTofu: use `count = var.enable_<service> ? 1 : 0` on the VM module and backup jobs; fallback outputs to `null`.
   - In Ansible: set `enable_<service>` in `ansible/group_vars/all/main.yml`. Classify active nodes into `active_nodes` dynamically in `site.yml` to prevent SSH attempts to unprovisioned VMs. Implement cleanups to purge disabled reverse proxy routes and deconfigure host port forwards.

## 5. Virtual Machine Addition Workflow

When adding a new virtual machine workload to the infrastructure, follow this sequential workflow across all layers:

### Step 1: Determine Environment, Category & Allocations

1. **Environment (Category)**: Choose `core`, `dev`, or `prod` per `docs/conventions/naming.md`.
2. **Type (Subcategory)**: Choose `coord` (core coordinator only), `app` (application workload), or `data` (database / stateful store).
3. **Naming**: Format as `<environment>-<type>-<name>` (e.g. `dev-app-api`, `core-coord-gitea`).
4. **VMID & Subnet**: Select an available VMID within the allocated range (Core: `1000-1999`, Dev: `2000-2999`, Prod: `3000-3999`) and assign an IP within the appropriate SDN VNet (`vcoord`, `vcore`, `vcdb`, `vddb`, `vpdb`) per `docs/conventions/networking.md`.
5. **Resource Pool**: Map to the matching pool (`core_coord`, `core_app`, `core_data`, `dev_data`, `prod_data`).

### Step 2: OpenTofu Infrastructure Code

1. **Workload Definition**: Create `opentofu/vms/<name>.tf`:
   - Call the unified VM module (`source = "../modules/vm"`).
   - Set `name`, `node_name`, `vm_id`, `pool_id`, `cores`, `memory`, `disk_size`, `image_id`, `vnet_id`, `ipv4_address`, `ipv4_gateway`, `ssh_public_keys`.
   - Declare declarative `firewall_rules` directly inside the workload file.
   - For stateful VMs, attach a daily snapshot backup job (`proxmox_backup_job`).
   - For optional services, add `count = var.enable_<service> ? 1 : 0` to both the VM module and backup job.
2. **Variables & Outputs**:
   - If feature-flagged, add `enable_<service>` in `opentofu/variables.tf`, `opentofu/vms/variables.tf`, and pass it through in `opentofu/vms.tf`.
   - Export VM ID and IP in `opentofu/vms/outputs.tf` and `opentofu/outputs.tf` (fallback to `null` if optional).
   - Update `opentofu/terraform.tfvars.example`.
3. **Validation**: Run `tofu validate` in `opentofu/`.

### Step 3: Secrets & Sensitive Configuration (Sanitized)

1. **Documentation Templates**:
   - If the workload requires passwords or tokens, declare sanitized template keys in `ansible/group_vars/all/secrets.yml.example` and `vault.yml.example`.
   - Update `/srv/secrets/<service>_*` generation tasks in `ansible/roles/bootstrap/tasks/main.yml` if secrets should be auto-provisioned.
2. **Security Compliance**: Never commit plaintext secrets, tokens, or environment-specific credentials to Git.

### Step 4: Ansible Configuration Code

1. **Inventory**: Add the VM to `ansible/inventory/hosts.ini` under the corresponding tier group (`core_coordinators`, `core_apps`, `dev_apps`, etc.) and ensure parent groups (`docker_hosts`, `vms`) include it.
2. **Role or Playbook Tasks**:
   - Create a dedicated role in `ansible/roles/<service>/` or assign an existing role.
   - If containerized, create `docker-compose.yml.j2` and role tasks deploying the service.
3. **Ingress & Port Forwarding**:
   - **Reverse Proxy**: If accessible via HTTP/HTTPS, add a site entry to `caddy_sites` in `ansible/group_vars/core_coordinators.yml` with `enabled` toggle.
   - **Host Port Forwarding**: If exposing external non-HTTP ports on the host, declare systemd proxy rules in `host_port_forwards` in `ansible/group_vars/proxmox.yml`.
4. **Playbook Integration**:
   - Add a deployment play to `ansible/site.yml` targeting `<group>:&active_nodes`.
   - If optional, add `enable_<service>: true` in `ansible/group_vars/all/main.yml` and include the hostname in the `active_nodes` classifier task in `site.yml`.

### Step 5: Documentation & Requirements Traceability (OFT)

1. **Architecture & Usage Docs**:
   - Update `docs/idea.md` (environment / VM allocation tables).
   - Update `docs/usage.md` with relevant Ansible tags, operational commands, or container management runbooks.
   - Update `docs/setup.md` if the bootstrap sequence changes.
2. **OpenFastTrace**:
   - If introducing new architecture capabilities or security boundaries, add corresponding `req~...` items under appropriate `feat~...` in `docs/requirements.md`.
   - Add implementation tags (`[impl->req~...]`) in code/playbooks and operational tags (`<!-- [oman->req~...] -->`) in docs.
   - Run `oft trace -v all .` to verify 100% trace coverage and zero defects.

## 6. Deployment Workflow (Server-First Execution)

All live infrastructure commands and OpenTofu state reside exclusively on the target server in `/srv/admin`:

1. **Develop**: Edit configurations and documentation locally on your workstation.
2. **Verify**:
   - Run `tofu validate` in `opentofu/`.
   - Run `oft trace -v all .` to ensure 100% requirements trace coverage.
   - Run `npx markdownlint-cli "**/*.md"` to verify documentation formatting.
   - Run pre-commit checks (`pre-commit run --all-files`) and inspect `git status` / `git diff --staged` to guarantee no `.env`, `PRIVATE.md`, private keys, hostnames, or credentials are staged.
3. **Push**: Push commits to GitHub (`git push origin main`).
4. **Deploy on the target server**:
   - Connect to the server via SSH (`ssh <server>` from `PRIVATE.md`).
   - Pull the latest commits: `cd /srv/admin && git pull origin main`.
   - Apply OpenTofu (infrastructure):

     ```bash
     cd /srv/admin/opentofu
     tofu plan
     tofu apply
     ```

   - Apply Ansible (configuration):

     ```bash
     cd /srv/admin/ansible
     ansible-playbook -i inventory/hosts.ini site.yml
     ```
