# Use OpenTofu for Provisioning Instead of Terraform

- Status: accepted
- Date: 2026-10-28

## Context and Problem Statement

We need an Infrastructure-as-Code (IaC) tool for provisioning the Proxmox environment, creating VMs, LXC containers, networks, and other cloud/server resources. The tool must provide declarative state management, strong provider support (specifically for Proxmox VE), and long-term licensing stability.

## Decision Drivers

- Mature and active community
- Stability and reliability for production infrastructure
- Preference for a truly open-source solution with community governance

## Considered Options

- OpenTofu
- HashiCorp Terraform

## Decision Outcome

Chosen option: "OpenTofu", because it is an open-source, community-driven fork governed under the Linux Foundation with a permissive MPL-2.0 license, avoiding HashiCorp's BSL licensing restrictions while maintaining full compatibility with the Terraform/OpenTofu provider ecosystem.

### Positive Consequences

- Fully open-source and free from commercial licensing constraints.
- Direct drop-in compatibility with the modern `bpg/proxmox` provider.
- Native state encryption and modern IaC features.

### Negative Consequences / Conventions

- **Documentation Convention**: While commands are executed internally using OpenTofu (`tofu init`, `tofu plan`, `tofu apply`), documentation and directory structures will continue to use the term "Terraform" (e.g. `terraform/` folder), as it is the universally recognized industry terminology that operators and contributors are used to.

## Pros and Cons of the Options

### OpenTofu

- Good, because it is under Linux Foundation governance with open-source licensing.
- Good, because it maintains drop-in HCL syntax and provider registry compatibility.
- Good, because it has an active and growing community.

### HashiCorp Terraform

- Good, because it is the original mature industry standard.
- Bad, because the Business Source License (BSL) restricts open-source usage and future redistribution.
