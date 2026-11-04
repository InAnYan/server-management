# Permissions & Access Control

Operational boundaries, resource pool isolation, and access delegation across the infrastructure stack.

## Resource Pools & Permission Boundaries

To align administrative boundaries with network tiers, workloads are organized into dedicated Proxmox Resource Pools matching each VNet category:

- **Core Pools**:
  - `core-coord`: Core coordinator workloads (Caddy, Gitea, Uptime Kuma).
  - `core-app`: Core application workloads (Technitium, Uptime Kuma).
  - `core-data`: Core data and database persistence workloads.
- **Dev Pools**:
  - `dev-app`: Development application workloads.
  - `dev-data`: Development data and database persistence workloads.
- **Prod Pools**:
  - `prod-app`: Production application workloads.
  - `prod-data`: Production data and database persistence workloads.

## Automated Backup Policies

<!-- [oman->req~backups-opentofu~1] -->
Scheduled daily backups with a retention policy of 3 snapshots (`keep-last = 3`) are enforced across stateful workloads:

### Pool-Level Backups

All guests assigned to dedicated data storage pools are backed up automatically as a group:

- `backup-core-data`: Backs up all guests in the `core-data` pool daily.
- `backup-dev-data`: Backs up all guests in the `dev-data` pool daily.
- `backup-prod-data`: Backs up all guests in the `prod-data` pool daily.

### Dedicated Individual VM Backups

If a virtual machine stores state locally on its own disk rather than residing within a stateful data pool (such as coordinator or application services maintaining local SQLite databases, configuration repositories, or certificates), it is assigned a dedicated individual backup job:

- `backup-core-coord-caddy`: Backs up `core-coord-caddy` (VMID `1000`) for TLS certificates and custom routing configurations.
- `backup-core-coord-uptimekuma`: Backs up `core-coord-uptimekuma` (VMID `1100`) for monitoring history and SQLite configuration.
- `backup-core-coord-gitea`: Backs up `core-coord-gitea` (VMID `1200`) for repository storage and local Git data.
- `backup-core-app-technitium`: Backs up `core-app-technitium` (VMID `1500`) for DNS zone configurations and record databases.
