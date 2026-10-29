# Networking Architecture

Overview of the network configuration, host firewall rules, and network interfaces.

---

## Host Firewall & Port Exposure

The Proxmox VE host firewall enforces a default `DROP` policy on all incoming traffic (`input_policy = "DROP"`) while permitting outgoing traffic (`output_policy = "ACCEPT"`).

Only three specific ports are allowed for host access:

- **UDP 41641 (Tailscale Daemon)**: Accessible to anyone to allow the Tailscale WireGuard engine to negotiate direct peer-to-peer tunnels and communicate with coordination servers.
- **TCP 22 (SSH)**: Allowed **only** to Tailscale users (restricted to the `tailscale0` interface and the `100.64.0.0/10` CGNAT subnet). Connections from the public internet or local LAN are dropped.
- **TCP 8006 (Proxmox Web GUI)**: Allowed **only** to Tailscale users (restricted to the `tailscale0` interface and the `100.64.0.0/10` CGNAT subnet).

---

## Network Interfaces

### `tailscale0`

- Virtual point-to-point network interface created and managed by the Tailscale daemon.
- Handles all authenticated, WireGuard-encrypted mesh network traffic.
- Packets entering this interface are cryptographically validated by Tailscale node keys before reaching host services (SSH and web dashboard).

### `vmbr0`

- Default Linux network bridge created automatically during Proxmox VE installation.
- Attached to the physical network adapter to provide local LAN connectivity, default gateway routing, and outbound internet access for the host.
