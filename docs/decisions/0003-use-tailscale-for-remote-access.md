# Use Tailscale for Remote Access

- Status: accepted
- Date: 2026-10-28

## Context and Problem Statement

[ADR-0002](0002-use-tailscale-for-secure-access-to-the-server-and-internal-server-network.md) determined that a mesh overlay network service should be used to provide secure administrative access to the Proxmox host and internal VM networks. Which specific service and implementation should be selected?

## Decision Drivers

- **Ease of use**: The setup and daily connection experience must be frictionless across operator workstations (the most critical driver).
- **Third-party independence**: Preference for solutions that avoid external dependencies where practical.
- **Open-source preference**: Preference for open-source clients and protocols.

## Considered Options

- Tailscale
- Headscale (self-hosted Tailscale control server)
- NetBird
- ZeroTier

## Decision Outcome

Chosen option: "Tailscale", because ease of use is the primary decision driver. Tailscale provides seamless zero-configuration installation (`curl -fsSL https://tailscale.com/install.sh | sh`), rock-solid NAT traversal (DERP relays), official client applications across all major operating systems (macOS, iOS, Linux, Windows), and zero infrastructure maintenance required for the control plane.

### Positive Consequences

- Fast onboarding with single-command setup on the host and native desktop/mobile clients.
- Battle-tested WireGuard encryption with automated key exchange.
- Easy subnet router configuration to reach internal Proxmox VM networks.
- Retains future flexibility to migrate to self-hosted Headscale if third-party independence becomes prioritized later.

### Negative Consequences

- Relies on Tailscale's hosted coordination server for node discovery and authentication.

## Pros and Cons of the Options

### Tailscale

- Good, because it is the most mature and easiest solution with zero control plane maintenance.
- Good, because open-source client code and WireGuard core protocol.
- Bad, because the coordination server is hosted by a third party.

### Headscale

- Good, because it is open-source and self-hosted with no third-party reliance.
- Bad, because it requires deploying and maintaining an external server, database, and certificates just to bootstrap VPN access.

### NetBird

- Good, because it offers an open-source platform with both hosted and self-hosted options.
- Bad, because it has a smaller ecosystem and less mature client integrations compared to Tailscale.

### ZeroTier

- Good, because it is a mature network virtualization tool.
- Bad, because it uses a proprietary protocol (not WireGuard) and has more complex network configuration.
