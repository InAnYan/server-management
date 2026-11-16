# Permissions & Access Control

Operational boundaries, resource pool isolation, and access delegation across the infrastructure stack.

## Resource Pools & Permission Boundaries

To align administrative boundaries with network tiers, workloads are organized into dedicated Proxmox Resource Pools matching each VNet category:

- **Core Pools**:
  - `core-coord`: Core coordinator workloads (Caddy, Gitea, Gatus, Authentik).
  - `core-app`: Core application workloads (PowerDNS).
  - `core-data`: Core data and database persistence workloads.
- **Dev Pools**:
  - `dev-app`: Development application workloads.
  - `dev-data`: Development data and database persistence workloads.
- **Prod Pools**:
  - `prod-app`: Production application workloads.
  - `prod-data`: Production data and database persistence workloads.

## GitOps & Atlantis Proxmox VE Permissions

<!-- [oman->req~gitops-api-permissions-minimal~1] -->
The Atlantis GitOps automation operates under a dedicated Proxmox VE API token (`atlantis-prov@pve!tofu`). To enforce strict least-privilege boundaries, the token is granted scoped ACLs exclusively on application tiers:

| Proxmox Path | Role | Description |
| :--- | :--- | :--- |
| `/vms` | `PVEVMAdmin` | Full lifecycle and guest configuration control over virtual machines |
| `/pool/dev-app` | `PVEVMAdmin` | Full lifecycle control over development application VMs |
| `/pool/prod-app` | `PVEVMAdmin` | Full lifecycle control over production application VMs |
| `/sdn` | `PVESDNUser` | Permission to attach guest interfaces to SDN VNets (`vdev`, `vprod`) |
| `/storage/local` | `PVEDatastoreUser` | Read-only access to import base cloud images |
| `/storage/local-lvm` | `PVEDatastoreUser` | Allocate virtual disks in LVM-Thin |

The Atlantis token cannot access hypervisor system settings (`/nodes`, `/access`), core coordinators (`/pool/core-*`), or stateful database instances (`/pool/*-data`).

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
- `backup-core-coord-gatus`: Backs up `core-coord-gatus` (VMID `1100`) for monitoring configuration and endpoint definitions.
- `backup-core-coord-gitea`: Backs up `core-coord-gitea` (VMID `1200`) for repository storage and local Git data.
- `backup-core-coord-authentik`: Backs up `core-coord-authentik` (VMID `1450`) for identity engine configurations and local media/templates.
- `backup-core-app-dns`: Backs up `core-app-dns` (VMID `1500`) for PowerDNS and PowerDNS-Admin configuration states.
