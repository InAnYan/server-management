# Use Tailscale or Similar Mesh Service for Secure Access to Server and Internal Network

- Status: accepted
- Date: 2026-10-28

## Context and Problem Statement

We need remote administrative access to the Proxmox host (specifically for SSH management and the Proxmox web dashboard on port 8006), as well as seamless network connectivity to the internal server network to communicate directly with provisioned VMs and containers. We need an access mechanism that avoids exposing administrative interfaces to the public internet while keeping configuration manageable.

## Decision Drivers

- **Ease of use**: Setup, maintenance, and connection across operator workstations should require minimal effort.
- **Independence / Third-party reliance**: Preference for solutions that avoid external dependencies where possible.
- **Security**: Must minimize exposure to automated DDoS, port scans, and brute-force attacks from the public internet.

## Considered Options

- Expose ports 22 (SSH) and 8006 (Proxmox Web GUI) directly to the public IP
- Self-host and configure standalone WireGuard
- Use Tailscale or similar mesh overlay network service

## Decision Outcome

Chosen option: "Use Tailscale or similar mesh overlay network service", because it eliminates public attack surfaces entirely, provides zero-configuration NAT traversal, and connects administrators securely to both the host and internal VM subnets without opening firewall ports to the public internet.

### Positive Consequences

- Ports 22 and 8006 remain completely closed to the public internet, mitigating brute-force and DDoS risks.
- Administrators can reach the host and internal VM networks from any location without public port forwards.
- Automatic key rotation, WireGuard-based end-to-end encryption, and seamless multi-device support.

### Negative Consequences

- Introduces reliance on a mesh networking control plane (mitigated in follow-up decision ADR-0003).

## Pros and Cons of the Options

### Expose ports 22 and 8006 to the public IP

- Good, because it requires no VPN client software on workstations.
- Bad, because it exposes critical hypervisor management surfaces to constant scanning, DDoS, and zero-day vulnerabilities.
- Bad, because it does not grant direct access to private VM subnets without individual port forwards.

### Self-host and configure standalone WireGuard

- Good, because it is 100% self-hosted without any third-party involvement.
- Bad, because it requires manual key management, manual firewall port forwarding on external routers, and ongoing maintenance.
- Bad, because handling complex routing across multiple client devices requires extra operational overhead.

### Use Tailscale or similar mesh overlay network service

- Good, because it works behind NAT and firewalls with zero public ports open.
- Good, because it provides simple subnet routing to internal VMs.
- Bad, because typical hosted mesh services involve third-party coordination servers.
