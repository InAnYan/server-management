# Choose Gitea for Git Repository and Collaboration Platform

- Status: draft
- Date: 2026-11-03

## Context and Problem Statement

We need a self-hosted Git repository hosting and code collaboration platform to store project repositories, manage automation playbooks, support CI/CD pipelines, and provide team access control.

In full-scale enterprise and multi-node environments, the preferred and standard choice for an all-in-one DevOps platform is **GitLab** due to its mature ecosystem, integrated CI/CD runners, container registry, security scanning, and comprehensive project management features.

However, our current infrastructure runs on a single host with constrained hardware resources (limited CPU cores and RAM shared across hypervisor, routing, monitoring, and database tiers). We must balance functionality against strict memory constraints.

## Decision Drivers

- **Resource Consumption**: Must run reliably on a lightweight virtual machine (`core-coord-gitea`, 2 vCPU, 2 GB RAM) without starving other services.
- **Git Protocol Support**: Full support for Git over HTTP/HTTPS and Git over SSH (forwarded via port `2222`).
- **External Database Integration**: Support for connecting to the shared core PostgreSQL database (`core-data-postgres`) for persistence.
- **GitLab-Compatible Workflow**: Familiar pull/merge request model, issue tracking, and webhook integration compatible with modern CI/CD patterns.

## Considered Options

- GitLab (Self-Managed Community Edition)
- Gitea
- Forgejo
- Pure Git over SSH / cgit

## Decision Outcome

Chosen option: **"GitLab as the architectural standard, with Gitea selected for resource-limited deployments"**.

While GitLab remains the benchmark for enterprise code collaboration, self-hosted GitLab Omnibus requires a minimum of 4 vCPUs and 8-16 GB of RAM, which would monopolize a large portion of our single server's available capacity.

For resource-limited environments like ours, **Gitea** provides an optimal, lightweight drop-in solution. Written in Go, it delivers the essential collaboration features (repositories, pull requests, issue tracking, webhooks, SSH/HTTPS access) with a memory footprint of less than 200 MB RAM, connecting to our existing PostgreSQL persistence tier.

### Positive Consequences

- Low memory footprint (~100-200 MB RAM) allows reliable execution on a modest VM without impacting adjacent workloads.
- Uses existing PostgreSQL database infrastructure (`giteadb` on `core-data-postgres`).
- Fast startup and low CPU idle usage compared to Ruby/Rails or JVM alternatives.
- Built-in Git SSH daemon routing through port `2222` alongside HTTPS reverse proxying through Caddy.

### Negative Consequences

- Lacks GitLab's extensive built-in CI/CD orchestration and enterprise governance tooling out of the box (requires external runners or Gitea Actions).
- Advanced portfolio management and integrated security scanning require third-party tools.

## Pros and Cons of the Options

### GitLab (Self-Managed CE)

- Good, because comprehensive all-in-one DevOps platform with market-leading CI/CD pipelines and package registries.
- Good, because extensive ecosystem, enterprise tooling, and broad industry adoption.
- Bad, because extremely heavy resource requirements (minimum 4 CPU cores, 8 GB+ RAM baseline), making it impractical on a resource-constrained single-server host.

### Gitea

- Good, because ultra-lightweight Go application with negligible idle resource usage.
- Good, because provides familiar GitHub/GitLab-style web UI, pull requests, issue tracking, and webhooks.
- Good, because integrates directly with external PostgreSQL databases.
- Bad, because smaller built-in feature set compared to the complete GitLab suite.

### Forgejo

- Good, because community-governed soft fork of Gitea with identical low resource footprint.
- Bad, because Gitea has broader commercial ecosystem backing, slightly wider integration support, and established container distribution.

### Pure Git over SSH / cgit

- Good, because minimal possible resource usage (standard Linux utilities and lightweight C cgi).
- Bad, because lacks web-based pull requests, code reviews, user permission hierarchies, and webhook integrations needed for automated CI/CD.
