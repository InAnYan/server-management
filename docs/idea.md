# Infrastructure Architecture & Vision

Overview of the server utilization strategy and infrastructure organization.

---

## Three-Tier Architecture

The server infrastructure is organized into three distinct layers:

### 1. Server Setup (Host Level)

- Proxmox VE host settings, storage pools, and network bridges.
- Host firewall, kernel parameters, and system updates.
- Base security: SSH hardening, user accounts, and Tailscale VPN.

### 2. Core Infrastructure

- Shared foundational services required by downstream workloads.
- Core DNS server (internal name resolution).
- Reverse proxy and TLS certificate automation.
- Essential shared utilities (Git hosting, monitoring with Uptime Kuma).

### 3. End-User & Lab Services

- User applications, lab research services, and internal projects.
- Subdivided into isolated environments:
  - **Development Environment**: Staging instances, testing containers, and active development sandboxes.
  - **Production Environment**: High-availability, persistent services with backup schedules.

---

## Operational Environment

- This repository is designed to be cloned and run directly on the Proxmox host.
- Shared location across administrators: `/srv/admin`.
