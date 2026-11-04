# Server Management Infrastructure

Production-grade Infrastructure-as-Code (IaC) repository for provisioning, configuring, and maintaining a self-hosted Proxmox VE server operating under a **single public IP address**.

Infrastructure provisioning is automated via **OpenTofu**, and operating system configuration and service runtimes are orchestrated through **Ansible**.

## Core Features & Technologies

- **Hypervisor Automation (OpenTofu / `opentofu/`)**:
  - Declarative Proxmox VE management using the `bpg/proxmox` provider.
  - Software-Defined Networking (SDN) simple zone with 7 isolated VNets across `10.0.0.0/8`.
  - Resource pool isolation (`core-coord`, `core-app`, `core-data`, `dev-app`, `dev-data`, `prod-app`, `prod-data`).
  - Automated Debian 12 cloud image download and Cloud-Init initialization.
  - Granular virtual firewall rules and scheduled daily backup jobs.
- **Service Orchestration (Ansible / `ansible/`)**:
  - Automated host credential bootstrap and persistent secret generation in `/srv/secrets/`.
  - Hardened baseline configurations (non-root SSH key authentication, timesync, journald, unattended upgrades).
  - Docker container runtimes across all virtual machine nodes.
  - Core services: **Caddy** (TLS reverse proxy), **Technitium DNS** (authoritative DNS server), **Uptime Kuma** (monitoring & status page), and **Gitea** (lightweight Git collaboration platform).
  - Multi-tier relational database layer (**PostgreSQL**) with isolated instances for Core, Dev, and Prod environments.

## Documentation & Getting Started

To understand the architecture, bootstrap the server, and manage services, follow the documentation:

1. **[Infrastructure Architecture & Core Ideas](docs/idea.md)**: Conceptual foundations, single-IP routing model, and the 2D Environment &times; Type workload matrix.
2. **[Server Setup Guide](docs/setup.md)**: Complete step-by-step runbook from a bare Proxmox VE installation through OpenTofu provisioning and Ansible deployment.
3. **[Usage & Operations Guide](docs/usage.md)**: Daily operational commands, targeted tag execution, user account provisioning, and secret rotation.
4. **[Documentation Directory](docs/README.md)**: Central index covering conventions, architectural decisions (ADRs), security runbooks, and implementation guides.
