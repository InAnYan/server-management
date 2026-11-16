# Choose Virtual Machines over LXC Containers

- Status: draft
- Date: 2026-11-04

## Context and Problem Statement

Proxmox VE provides two primary workload virtualization technologies: Kernel-based Virtual Machines (KVM VMs) and Linux Containers (LXC). We need to determine the primary workload execution layer for running services (such as reverse proxies, authoritative DNS, monitoring dashboards, databases, and Git collaboration platforms). Workloads in this environment frequently run internal application containers via Docker and Docker Compose.

## Decision Drivers

- Security isolation and hypervisor-level trust boundaries
- Seamless execution of Docker and container runtimes inside workloads
- Operational uniformity across operating systems and network attachments
- Predictable kernel parameters, modules, and networking behavior
- Robust snapshotting, live backup, and failure containment

## Considered Options

- Virtual Machines (KVM) using Debian Cloud Image
- Unprivileged LXC Containers
- Privileged LXC Containers

## Decision Outcome

Chosen option: "Virtual Machines (KVM) using Debian Cloud Image", because VMs provide hardware-level virtualization with dedicated Linux kernels, establishing a robust security barrier against host-level kernel compromise. Furthermore, because several services run Docker inside the operating system, running Docker inside full VMs avoids the severe operational friction, nesting security trade-offs, and kernel capability leaks required to run Docker inside LXC containers.

### Positive Consequences

- **Hypervisor Boundary**: Every VM runs its own independent Linux kernel. A vulnerability or compromise within a VM cannot compromise the host kernel directly.
- **Docker Compatibility**: Docker and Docker Compose run natively within VMs without requiring nested container profiles (`features: nesting=1`), overlayfs workarounds, or custom AppArmor profiles.
- **Unified OS Lifecycle**: All nodes boot uniformly from a standardized Debian cloud image via Cloud-Init, ensuring identical base configurations and predictable storage interfaces (`virtio-scsi-pci`).
- **Network Isolation**: Proxmox SDN VNets and firewall rules attach cleanly to VirtIO network devices.

### Negative Consequences

- **Resource Overhead**: Full virtualization consumes dedicated RAM and disk space for the guest kernel and operating system overhead compared to lightweight, shared-kernel LXC containers.
- **Boot Latency**: Full VM boot times (typically 10-15 seconds) are slower than instantaneous container startups.

## Pros and Cons of the Options

### Virtual Machines (KVM)

Hardware-assisted virtualization running an isolated guest operating system and dedicated Linux kernel.

- Good, because hardware-level virtualization provides strong security isolation between tenants and the Proxmox host.
- Good, because Docker and container runtimes execute natively with standard storage drivers and network bridging.
- Good, because OS-level kernel upgrades and module configurations are completely isolated from host stability.
- Bad, because each VM requires dedicated memory allocation and cannot dynamically share host RAM pages as efficiently as containers.

### Unprivileged LXC Containers

Operating system virtualization sharing the Proxmox host kernel with user namespace mapping.

- Good, because memory and CPU overhead is minimal, sharing the underlying host kernel directly.
- Good, because start times are nearly instantaneous.
- Bad, because running Docker inside unprivileged LXC containers requires nested virtualization hacks and storage driver adjustments (e.g. VFS or fuse-overlayfs) that impair performance and stability.
- Bad, because shared-kernel architecture increases vulnerability to kernel privilege escalations and local denial-of-service.

### Privileged LXC Containers

Operating system virtualization sharing the Proxmox host kernel without user namespace mapping.

- Good, because running nested Docker containers is simpler without user namespace ID mappings.
- Bad, because root inside the container is root on the host hypervisor, creating an unacceptable security hazard in a single-host environment.
