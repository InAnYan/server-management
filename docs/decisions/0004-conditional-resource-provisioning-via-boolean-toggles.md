# Conditional Resource Provisioning via Boolean Toggles

- Status: accepted
- Date: 2026-10-29

## Context and Problem Statement

The repository manages multiple infrastructure components and virtual machines/containers (e.g., core infrastructure services such as DNS, reverse proxy, monitoring). However, not every deployment or operator requires all defined services (for example, an operator might already have an external DNS server or may not need a local DNS container).

We need an idiomatic, maintainable mechanism in OpenTofu to conditionally enable or disable individual resources and VM definitions without modifying the core IaC codebase across different environments.

## Decision Drivers

- Simplicity: The configuration must be straightforward to read, configure, and debug.
- Low overhead: The number of optional services in the repository is relatively small, so excessive abstraction is unnecessary.
- Explicit configuration: It should be immediately obvious from variable definitions whether a resource will be provisioned.

## Considered Options

- Pattern 1: Boolean feature toggles (`var.enable_<service>`) using conditional `count`
- Pattern 2: Centralized tag/service list or map (e.g., `enabled_services = ["dns"]` with dynamic filtering)

## Decision Outcome

Chosen option: "Pattern 1: Boolean feature toggles (`var.enable_<service>`)", because simplicity is our primary decision driver. With a small, focused set of service components (such as DNS or monitoring), discrete boolean variables (e.g. `enable_dns_server = true/false`) coupled with resource-level `count = var.enable_dns_server ? 1 : 0` provide the cleanest and most transparent configuration. Approach 2 (a centralized list or map filter) was dropped as it adds unnecessary indirection and complexity for our scale.

### Positive Consequences

- Clear and declarative interface in `variables.tf` and `terraform.tfvars`.
- Standard, idiomatic OpenTofu/Terraform pattern familiar to all operators.
- Zero extra complexity or abstraction: resources are created when the boolean is `true` and skipped when `false`.
- Straightforward dependency handling for outputs and downstream references using conditional expressions or splat syntax.

### Negative Consequences

- Each new optional service introduces a dedicated boolean variable in the stack's `variables.tf`.
- If the number of optional resources grows significantly, maintaining flat boolean flags could become verbose (an accepted trade-off given the limited number of services in this setup).

## Pros and Cons of the Options

### Pattern 1: Boolean Feature Toggles (`var.enable_<service>`)

- Good, because it is the simplest and most explicit mechanism in OpenTofu/Terraform.
- Good, because variables are self-documenting with default values and descriptions in `variables.tf`.
- Good, because it requires no complex map lookups, collection filtering, or meta-programming.
- Bad, because each optional resource requires an individual variable definition.

### Pattern 2: Centralized Tag / Service List or Map

- Good, because multiple services can be enabled/disabled within a single list or map variable.
- Bad, because it introduces dynamic lookups (`lookup()`, `contains()`, `for` expressions) that obscure readability.
- Bad, because it adds unnecessary complexity for an infrastructure repository with only a few optional components.
