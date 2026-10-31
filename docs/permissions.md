# Permissions & Access Control

Operational boundaries, resource pool isolation, and access delegation across the infrastructure stack.

## Resource Pools & Permission Boundaries

To align administrative boundaries with network tiers, workloads are organized into dedicated Proxmox Resource Pools matching each VNet category:

- **Core Pools**:
  - `core-coord`: Core coordinator workloads (Caddy, Gitea, Infisical).
  - `core-app`: Core application workloads (Technitium, Uptime Kuma).
  - `core-data`: Core data and database persistence workloads.
- **Dev Pools**:
  - `dev-app`: Development application workloads.
  - `dev-data`: Development data and database persistence workloads.
- **Prod Pools**:
  - `prod-app`: Production application workloads.
  - `prod-data`: Production data and database persistence workloads.

## Automated Backup Policies

Scheduled daily backups with a retention policy of 3 snapshots (`keep-last = 3`) are enforced at the resource pool level for stateful data pools:

- `backup-core-data`: Backs up all guests in the `core-data` pool daily.
- `backup-dev-data`: Backs up all guests in the `dev-data` pool daily.
- `backup-prod-data`: Backs up all guests in the `prod-data` pool daily.
