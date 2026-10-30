# Infrastructure Architecture

Core idea of server utilization and infrastructure organization across three layers.

## 1. Server Setup

Setup of the Proxmox node itself.

**Linked places:**

- [docs/server_setup.md](server_setup.md): Manual host bootstrap steps (Proxmox install, user creation, SSH hardening, Tailscale, and `/srv/admin` setup).
- [`terraform/server_setup/`](../terraform/server_setup/): OpenTofu scripts for Proxmox host settings, network bridges, and storage pools.

## 2. Core Infrastructure

Essential foundational services (DNS server, reverse proxy, Git, etc.). These foundational services provide network and routing foundations rather than shared databases for user applications.

**Linked places:**

- [`terraform/core_infrastructure/`](../terraform/core_infrastructure/): OpenTofu stack for core infrastructure instances.
- [`terraform/uptime-kuma/`](../terraform/uptime-kuma/): Monitoring service. Run separately after `core_infrastructure` is provisioned and configured.

## 3. End-User Services

Projects and services that users or the lab require, run, and develop.

- Subdivided into environments:
  - **Development Environment**
  - **Production Environment**
- End-user services have their own dedicated instances (such as Postgres, Redis, and S3 object storage) rather than sharing database layers.
