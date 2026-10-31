# Naming Conventions

Standard naming rules, identifier structures, and numeric ranges across the infrastructure stack (Proxmox VE, OpenTofu, Ansible, and DNS).

## General Principles

- **Lowercase ASCII only**: All identifiers, hostnames, network devices, and resource identifiers must use English lowercase letters (`[a-z0-9-]`).
- **Hyphen delimiters**: Words and tokens are delimited by hyphens (`-`).
- **Structural separation preference**: Prefer separating logical and structural elements with hyphens rather than every individual English word (for example, `core-testapp` rather than `core-test-app`). This keeps compound identifiers concise, predictable, and structurally hierarchical.
- **No special characters**: Avoid underscores, dots, or spaces in machine and device names, except where strictly enforced by specific tooling syntax (such as Ansible group names which require underscores, e.g. `core_apps`).

## Machine Name

Virtual machines and LXC containers follow a strict three-part hierarchical naming schema:

```text
<category>-<subcategory>-<name>
```

### Schema Components

1. **`<category>`**: Defines the top-level governance boundary or operational tier:
   - `core`: Shared infrastructure, ingress routing, orchestration, and host-managed platforms.
   - `dev`: Development workloads, testing environments, and non-production instances.
   - `prod`: Production workloads, customer-facing services, and persistent operational systems.

2. **`<subcategory>`**: Defines the functional role and security isolation tier of the workload:
   - `coord`: Coordinators, reverse proxies, and orchestration gateways (e.g. Caddy, Gitea, Infisical).
   - `app`: Application compute workloads and microservices (e.g. Technitium, Uptime Kuma, test VMs).
   - `data`: Stateful persistence layers, relational databases, and key-value datastores (e.g. PostgreSQL, Redis).

3. **`<name>`**: Specific application or service identifier. May include an instance number if multiple instances exist:
   - Examples: `gitea`, `caddy`, `postgres`, `testvm`, `uptimekuma`, `technitium`.

### Examples

| Machine Name | Category | Subcategory | Description |
| :--- | :--- | :--- | :--- |
| `core-coord-gitea` | `core` | `coord` | Core Git repository and CI/CD coordinator |
| `core-coord-caddy` | `core` | `coord` | Ingress reverse proxy and TLS terminator |
| `core-app-testvm` | `core` | `app` | Baseline test virtual machine in core apps tier |
| `core-app-uptimekuma` | `core` | `app` | Infrastructure health monitoring service |
| `core-data-postgres` | `core` | `data` | PostgreSQL cluster backing core coordinator tools |
| `dev-app-web` | `dev` | `app` | Development application frontend/API |
| `dev-data-postgres` | `dev` | `data` | Development database instance |
| `prod-app-api` | `prod` | `app` | Production backend API service |
| `prod-data-postgres` | `prod` | `data` | Production primary database cluster |

## Machine ID (VMID / CT ID)

To maintain predictability across provisioning workflows, backup scripts, and inventories, machine IDs follow deterministic numeric allocations aligned with machine categories and subcategories:

| Tier / Subcategory | Machine ID Range (VMID / CT ID) | Name Prefix Pattern | Resource Pool |
| :--- | :--- | :--- | :--- |
| **Core Coordinators** | `1000` – `1499` | `core-coord-*` | `core-coord` |
| **Core Apps** | `1500` – `1899` | `core-app-*` | `core-app` |
| **Core Databases** | `1900` – `1999` | `core-data-*` | `core-data` |
| **Dev Apps** | `2000` – `2899` | `dev-app-*` | `dev-app` |
| **Dev Databases** | `2900` – `2999` | `dev-data-*` | `dev-data` |
| **Prod Apps** | `3000` – `3899` | `prod-app-*` | `prod-app` |
| **Prod Databases** | `3900` – `3999` | `prod-data-*` | `prod-data` |

## IP Addresses

All IP addresses, CIDR blocks, gateway assignments, and network topologies are documented in [docs/networking.md](networking.md).

## Network Devices

Virtual networks (Proxmox Software-Defined Networking VNets) follow the structured naming pattern:

```text
vnet-<category>-<subcategory>
```

### Virtual Network Canonical Names & Examples

- `vnet-core-coord`: Core Coordinator network (`10.10.1.0/24`)
- `vnet-core-app`: Core Applications network (`10.11.0.0/16`)
- `vnet-core-data`: Core Databases network (`10.10.2.0/24`)
- `vnet-dev-app`: Development Applications network (`10.21.0.0/16`)
- `vnet-dev-data`: Development Databases network (`10.20.2.0/24`)
- `vnet-prod-app`: Production Applications network (`10.32.0.0/16`)
- `vnet-prod-data`: Production Databases network (`10.30.2.0/24`)

### Technical Constraint on Proxmox VNet IDs

Proxmox VE Software-Defined Networking (SDN) and the Linux kernel bridge subsystem restrict the internal VNet `id` attribute to **8 characters or fewer**.

To comply with this constraint while preserving human-readable and standard naming across the platform:

1. The underlying Proxmox VNet `id` uses a compact identifier (<= 8 characters).
2. The descriptive canonical name (`vnet-<category>-<subcategory>`) is configured as the VNet's `alias` attribute in OpenTofu and Proxmox VE.

| Canonical Virtual Network Name | Proxmox SDN VNet ID (`id`) | Proxmox VNet Alias (`alias`) | Subnet CIDR |
| :--- | :--- | :--- | :--- |
| Core Coordinators | `vcoord` | `vnet-core-coord` | `10.10.1.0/24` |
| Core Applications | `vcore` | `vnet-core-app` | `10.11.0.0/16` |
| Core Databases | `vcdb` | `vnet-core-data` | `10.10.2.0/24` |
| Dev Applications | `vdev` | `vnet-dev-app` | `10.21.0.0/16` |
| Dev Databases | `vddb` | `vnet-dev-data` | `10.20.2.0/24` |
| Prod Applications | `vprod` | `vnet-prod-app` | `10.32.0.0/16` |
| Prod Databases | `vpdb` | `vnet-prod-data` | `10.30.2.0/24` |

### Host Interfaces

Host interfaces follow standard Linux conventions:

- `vmbr0`: Physical Linux network bridge bound to the host physical Ethernet interface for WAN and local LAN connectivity.
- `tailscale0`: Tailscale WireGuard virtual tunnel interface.
