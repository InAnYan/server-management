# Networking Architecture

Overview of the network configuration, host firewall rules, network interfaces, and virtual machine / container network topology.

## Host Firewall & Port Exposure

<!-- [oman->req~firewall-enabled~1] -->
The Proxmox VE host firewall enforces a default `DROP` policy on all incoming traffic (`input_policy = "DROP"`) while permitting outgoing traffic (`output_policy = "ACCEPT"`).

Only specific ports are allowed for host access:

- **UDP 41641 (Tailscale Daemon)**: Accessible to anyone to allow the Tailscale WireGuard engine to negotiate direct peer-to-peer tunnels and communicate with coordination servers.
- **TCP 22 (SSH)**: Allowed **only** to Tailscale users (restricted to the `tailscale0` interface and the `100.64.0.0/10` CGNAT subnet). Connections from the public internet or local LAN are dropped.
- **TCP 8006 (Proxmox Web GUI)**: Allowed **only** to Tailscale users (restricted to the `tailscale0` interface and the `100.64.0.0/10` CGNAT subnet).
- **TCP 80 (HTTP) & TCP 443 (HTTPS)**: Accessible on the host (`vmbr0` and `tailscale0`) to receive web traffic and forward it via `systemd-socket-proxyd` to the Caddy reverse proxy VM (`core-coord-caddy`, `10.10.1.10`).

## Host Port Forwarding (`systemd-socket-proxyd`)

<!-- [oman->req~host-port-forwarding-ansible~1] -->
Host-level ingress traffic for HTTP (80) and HTTPS (443) is forwarded to `core-coord-caddy` (`10.10.1.10`) using systemd socket activation and `systemd-socket-proxyd`:

- Systemd binds to `0.0.0.0:80` and `0.0.0.0:443` via dedicated `.socket` units (`port-forward-caddy-ingress-80.socket`, `port-forward-caddy-ingress-443.socket`).
- On incoming connections, systemd triggers `systemd-socket-proxyd` services that stream TCP traffic directly to `10.10.1.10`.
- This Layer 4 stream proxy eliminates iptables DNAT conflicts, conntrack zone isolation issues introduced by Proxmox SDN firewall bridges (`CT --zone 1`), and Tailscale forward filtering issues.

## Network Interfaces

### `tailscale0`

- Virtual point-to-point network interface created and managed by the Tailscale daemon.
- Handles all authenticated, WireGuard-encrypted mesh network traffic.
- Packets entering this interface are cryptographically validated by Tailscale node keys before reaching host services (SSH and web dashboard).

### `vmbr0`

- Default Linux network bridge created automatically during Proxmox VE installation.
- Attached to the physical network adapter to provide local LAN connectivity, default gateway routing, and outbound internet access for the host.

## Virtual Machine & Container Network Architecture (`10.0.0.0/8`)

All virtual machines and LXC containers reside within the private `10.0.0.0/8` address space. This address space is divided into distinct subnetworks categorized by operational tier and environment.

### Subnetwork Segmentation

| Subnetwork Category | Purpose / Example Workloads | Subnet CIDR | Internet Access (SNAT) |
| :--- | :--- | :--- | :--- |
| **Core Coordinator Apps** | Orchestration & routing (Gitea, Caddy, Uptime Kuma) | `10.10.1.0/24` | Yes |
| **Core Apps** | Internal core services (Technitium DNS, Uptime Kuma) | `10.11.0.0/16` | Yes |
| **Core Databases** | Dedicated persistence for core services | `10.10.2.0/24` | No |
| **Dev Apps** | Development application workloads | `10.21.0.0/16` | Yes |
| **Dev Databases** | Development persistence layer | `10.20.2.0/24` | No |
| **Prod Apps** | Production application workloads | `10.32.0.0/16` | Yes |
| **Prod Databases** | Production persistence layer | `10.30.2.0/24` | No |

## Inter-Subnet Communication & Access Rules

Strict isolation is maintained between environments to implement least-privilege network segmentation:

- **Core Coordinator Apps**: Serve as the central management and routing hub. They are permitted to communicate with:
  - Core Apps
  - Core Databases
  - Dev Apps
  - Prod Apps
- **Core Apps**: Permitted to communicate only with **Core Databases**.
- **Dev Apps**: Permitted to communicate only with **Dev Databases**.
- **Prod Apps**: Permitted to communicate only with **Prod Databases**.
<!-- [oman->req~cross-environment-isolation~1] -->
- **Environment Isolation**: Core, Dev, and Prod subnetworks are strictly separated. Workloads in Dev cannot reach Prod or Core workloads (and vice versa), with the sole exception of ingress/coordination mediated by the Core Coordinator apps.
<!-- [oman->req~databases-isolated-from-internet~1] -->
- **Internet Access**:
  - Application tiers (**Core Coordinator**, **Core Apps**, **Dev Apps**, and **Prod Apps**) have outbound internet access for package updates, dependencies, and external APIs.
  - Database tiers (**Core Databases**, **Dev Databases**, and **Prod Databases**) have **no** internet access, as databases do not require external connectivity.

```mermaid
flowchart TD
    subgraph External["External Networks"]
        Internet["Public Internet (WAN)"]
        Tailscale["Tailscale Mesh (100.64.0.0/10)"]
    end

    subgraph HostGateway["Proxmox VE Host Edge (vmbr0)"]
        HostIngress["Host Edge & Ingress Proxy<br/>Ports 80/443 &rarr; Caddy (vcoord)<br/>Port 53 &rarr; Technitium (vcore)<br/>Port 2222 &rarr; Gitea (vcoord)<br/>Ports 22/8006 &rarr; Tailscale Only"]
    end

    subgraph CoreTier["Core Environment"]
        vcoord["Core Coordinator (10.10.1.0/24)<br/>vnet-core-coord: Caddy, Uptime Kuma, Gitea"]
        vcore["Core Apps (10.11.0.0/16)<br/>vnet-core-app: Technitium DNS"]
        vcdb["Core Data (10.10.2.0/24)<br/>vnet-core-data: PostgreSQL, Valkey, MinIO"]
    end

    subgraph DevTier["Dev Environment"]
        vdev["Dev Apps (10.21.0.0/16)<br/>vnet-dev-app: APIs, Web Workloads"]
        vddb["Dev Data (10.20.2.0/24)<br/>vnet-dev-data: PostgreSQL, Valkey, MinIO"]
    end

    subgraph ProdTier["Prod Environment"]
        vprod["Prod Apps (10.32.0.0/16)<br/>vnet-prod-app: Production APIs, Workloads"]
        vpdb["Prod Data (10.30.2.0/24)<br/>vnet-prod-data: PostgreSQL, Valkey, MinIO"]
    end

    %% External Ingress
    Tailscale -->|"ALLOW: SSH 22, PVE GUI 8006"| HostIngress
    Internet -->|"ALLOW: HTTP 80, HTTPS 443"| HostIngress
    Internet -->|"ALLOW: DNS 53, Git SSH 2222"| HostIngress
    HostIngress -->|"Route HTTP/S"| vcoord
    HostIngress -->|"Proxy DNS"| vcore
    HostIngress -->|"Proxy Git SSH"| vcoord

    %% Coordinator Management Flows (Allowed)
    vcoord -->|"ALLOW: Manage / Route"| vcore
    vcoord -->|"ALLOW: Manage / Route"| vcdb
    vcoord -->|"ALLOW: Ingress / Route"| vdev
    vcoord -->|"ALLOW: Manage / Monitor"| vddb
    vcoord -->|"ALLOW: Ingress / Route"| vprod
    vcoord -->|"ALLOW: Manage / Monitor"| vpdb

    %% Intra-Environment Flows (Allowed)
    vcore -->|"ALLOW: Query / Store"| vcdb
    vdev -->|"ALLOW: Intra-Dev Data"| vddb
    vprod -->|"ALLOW: Intra-Prod Data"| vpdb

    %% Outbound Internet Egress (SNAT Allowed)
    vcoord -->|"ALLOW: SNAT Egress"| Internet
    vcore -->|"ALLOW: Upstream DNS Egress"| Internet
    vdev -->|"ALLOW: SNAT Egress"| Internet
    vprod -->|"ALLOW: SNAT Egress"| Internet

    %% Native Datacenter Firewall DROP Rules
    vdev -.-x|"DROP: Cross-Env Isolation"| vprod
    vdev -.-x|"DROP: Cross-Env Isolation"| vpdb
    vddb -.-x|"DROP: Cross-Env Isolation"| vpdb
    vdev -.-x|"DROP: Cross-Tier Isolation"| vcore
    vdev -.-x|"DROP: Cross-Tier Isolation"| vcdb
    vprod -.-x|"DROP: Cross-Tier Isolation"| vcore
    vprod -.-x|"DROP: Cross-Tier Isolation"| vcdb
    vcdb -.-x|"DROP: Zero Internet Egress"| Internet
    vddb -.-x|"DROP: Zero Internet Egress"| Internet
    vpdb -.-x|"DROP: Zero Internet Egress"| Internet
```

## Proxmox SDN & Firewall Implementation

1. **Proxmox Software-Defined Networking (SDN)**:
   - Each subnet is defined as an independent **VNET** within a Proxmox SDN Zone.
   - VNETs isolate Layer 2 broadcast domains across all VM and container workloads.
   - Proxmox SDN automatically registers IP sets for each VNet (`+sdn/<vnet>-all`), making subnets addressable in cluster firewall rules.
2. **Datacenter / Cluster Firewall Rules**:
   - Traffic crossing VNET boundaries is filtered through native Proxmox VE datacenter firewall forward rules using the modern nftables engine.
   - Explicit forward ALLOW rules permit authorized communications (Core coordinator to all tiers, intra-environment app-to-data, and application WAN egress).
   - Explicit forward DROP rules strictly isolate environments (Dev &harr; Prod, cross-tier access) and block database subnets from WAN egress.
   - Default datacenter forward policy is set to `DROP` (`forward_policy: DROP`).
3. **Internet Access via SNAT**:
   - Outbound internet access is controlled by toggling the **SNAT** (Source NAT) option on each SDN subnet definition.
   - SNAT is enabled for application subnets and disabled for database subnets.
