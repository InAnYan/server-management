# Choose Debian Cloud Image for Virtual Machines

- Status: accepted
- Date: 2026-10-30

## Context and Problem Statement

We need a standardized base operating system image to provision Virtual Machines (VMs) across our Proxmox VE environment. The base OS must support fully automated provisioning via OpenTofu and Cloud-Init, integrate seamlessly with Ansible for configuration management, and serve as a reliable platform for both containerized workloads and native services.

## Decision Drivers

- **Ansible Compatibility**: Includes Python pre-installed so Ansible can execute modules immediately without a bootstrap phase.
- **Minimal & Lightweight**: Low memory and storage footprint, fast provisioning and boot times.
- **Modern & Secure**: Maintained by an active community with timely security updates and long-term stability.
- **Container Support**: First-class support for running Docker containers and container runtimes.
- **Customizability**: Flexible enough to install and run native services and system packages, not strictly limited to container engines.
- **Cloud-Init Integration**: Native, reliable support for Cloud-Init initialization out of the box in Proxmox VE.

## Considered Options

- Debian Cloud Image (`genericcloud` / `nocloud`)
- Flatcar Container Linux
- Alpine Linux
- Fedora CoreOS

## Decision Outcome

Chosen option: "Debian Cloud Image", because it satisfies all decision drivers with zero friction:

1. **Python Included**: Debian Cloud images provide a minimal Python 3 environment out of the box, allowing Ansible playbooks to run on first boot without custom bootstrap workarounds.
2. **Minimal & Fast**: Stripped of desktop and unnecessary server packages, providing a lightweight, lean foundation.
3. **Broad Flexibility**: Unlike immutable container OSes, standard `apt` repositories allow running native services, monitoring agents, and Docker side by side.
4. **First-Class Proxmox & Cloud-Init**: Proxmox VE cloud-init drive support works natively with standard Debian cloud images.

### Positive Consequences

- Cloud-Init can configure hostnames, network interfaces, and SSH keys (`ansible` and `admin` users) deterministically at first boot.
- Ansible configuration begins immediately without needing raw shell/ssh bootstrapping to install Python.
- Proven stability and security track record of Debian stable releases.
- Broad compatibility with third-party software, utilities, and Docker without libc or immutability constraints.

### Negative Consequences

- Requires standard OS lifecycle management (APT updates and maintenance) compared to fully automated atomic updates found in immutable distributions like Flatcar or Fedora CoreOS.

## Pros and Cons of the Options

### Debian Cloud Image

- Good, because Python 3 is available by default, enabling instant Ansible readiness.
- Good, because it is minimal, lightweight, and purpose-built for cloud/virtualization environments.
- Good, because it has full access to the standard Debian package ecosystem (`apt`).
- Good, because it supports standard Cloud-Init drives natively in Proxmox VE.
- Bad, because it is not an immutable filesystem, requiring conventional patch management.

### Flatcar Container Linux

- Good, because it provides an immutable root filesystem with automated, atomic operating system updates.
- Good, because it is optimized specifically for running container workloads.
- Bad, because it does not ship with Python, making standard Ansible playbooks fail without complex Ignition/torcx workarounds.
- Bad, because the read-only root filesystem prevents installing custom non-container software or standard system packages.

### Alpine Linux

- Good, because it has an extremely small disk and memory footprint.
- Good, because boot times are fast and resource overhead is minimal.
- Bad, because it uses `musl` libc instead of `glibc`, causing binary compatibility issues with several applications and Python wheels.
- Bad, because it uses OpenRC instead of systemd, requiring custom service management definitions in Ansible playbooks.

### Fedora CoreOS

- Good, because it is a modern, secure, auto-updating container-centric operating system.
- Good, because it uses modern SELinux and Podman container integrations.
- Bad, because it relies on Ignition instead of standard Proxmox Cloud-Init configuration drives.
- Bad, because it does not include Python by default for Ansible management without containerized execution.
