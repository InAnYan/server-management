# Infrastructure Documentation

Central documentation directory for the Proxmox VE infrastructure stack, OpenTofu provisioning, and Ansible configuration.

## General Documentation

- [Infrastructure Architecture & Core Ideas](idea.md): Foundational design principles, single-IP routing model, and the 2D Environment &times; Type workload matrix.
- [Server Setup Guide](setup.md): Complete bootstrap runbook starting from a fresh Proxmox VE installation through OpenTofu and Ansible deployment.
- [Usage & Operations Guide](usage.md): Day-to-day administration commands, tag-based execution, and dedicated operational playbooks (`playbooks/ops/`).
- [Infrastructure Requirements](requirements.md): System features and functional requirements managed with OpenFastTrace.
- [Pull Request & GitOps Workflow](pr_workflow.md): Complete GitOps lifecycle, PR verification, Atlantis OpenTofu provisioning, Gitea Actions CI/CD, and VM workload setup.
- [Project Onboarding & Deployment Tutorial](tutorials/project_onboarding.md): Step-by-step developer guide on creating an Infisical project, configuring Gitea and Atlantis, declaring OpenTofu and Ansible, and setting up CI/CD workflows.

## Architectural Decision Records (ADRs)

- [Architectural Decision Records](decisions/README.md): Record of architectural choices, technical evaluations, and operational decisions formatted in MADR.

## Conventions

- [Conventions Index](conventions/README.md): Structural rules and standardized identifiers.
  - [Naming Conventions](conventions/naming.md): Machine naming schema (`<category>-<subcategory>-<name>`) and deterministic VMID allocations (`1000`–`3999`).
  - [Networking Architecture](conventions/networking.md): Host firewall rules, Tailscale isolation, Layer 4 socket streaming, and private subnets (`10.0.0.0/8`).
  - [Permissions & Access Control](conventions/permissions.md): Resource pools and automated daily backup policies.
  - [Requirements & Traceability](conventions/requirements.md): OpenFastTrace (OFT) specification management, traceability chains (`feat -> req -> impl/oman`), and tagging conventions.

## Implementation

- [Implementation Index](implementation/README.md): Technical implementation details.
  - [Virtual Machine Setup Guide](implementation/vm_setup.md): Base OS standards, Cloud-Init initialization, and account management.

## Security

- [Security Index](security/README.md): Security policies, threat analyses, and credential rotation procedures.
  - [Secrets Management Strategy](security/secrets_management.md): Secrets handling policy, local plaintext storage rules, and defense-in-depth protections.
  - [Secrets Rotation Plan](security/secrets_rotation_plan.md): Ingress-isolated credential rotation and operational runbooks.
  - [Potential Security Issues](security/potential_security_issues.md): Security threat modeling and risk mitigations.
- [Security Incident Reports](incidents/README.md): Post-incident analysis reports, root cause investigations, and remediation logs.
