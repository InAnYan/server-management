# Re-adopt Technitium DNS Server with Native OpenID Connect SSO

- Status: accepted
- Date: 2026-11-13
- Supersedes: [ADR-0016](0016-choose-powerdns-and-powerdns-admin-for-dns.md)

## Context and Problem Statement

The platform requires an authoritative and recursive DNS service to manage the primary domain zone, resolve service hostnames across internal SDN subnets, and expose an administrative interface for operators.

In [ADR-0016](0016-choose-powerdns-and-powerdns-admin-for-dns.md), PowerDNS and PowerDNS-Admin were chosen under the assumption that Technitium DNS Server lacked native OpenID Connect (OIDC) Single Sign-On (SSO). However, modern versions of Technitium DNS Server (v13+) feature native OIDC SSO with authorization code flow, automatic user provisioning, and remote group-to-role mapping.

Running PowerDNS required maintaining three separate container services (`pdns`, `recursor`, and `powerdns-admin`), along with an external relational database (`core-data-postgres`) housing multiple schemas. This introduced unnecessary operational complexity, container coordination overhead, and configuration synchronization hurdles.

We need a lightweight, self-contained DNS server and web console that provides native OIDC SSO, built-in recursive caching and authoritative DNS resolution, and automated REST API management.

## Decision Drivers

- **Simplicity and Footprint**: Single self-contained container eliminating external database dependencies, multi-container orchestration, and high RAM overhead.
- **Native OIDC SSO**: Native integration with Authentik ([ADR-0014](0014-choose-authentik-as-central-identity-provider.md)) via `/sso/callback`, supporting group mapping (`admins` to `Administrators`) and auto-signup.
- **Unified Engine**: Built-in recursive caching resolver and authoritative zone manager in a single runtime.
- **Declarative Automation**: Comprehensive HTTP REST API allowing Ansible to manage zones, baseline records, and forwarders idempotently.

## Considered Options

- Technitium DNS Server (v13+)
- PowerDNS + PowerDNS-Admin (current)
- BIND 9
- CoreDNS

## Decision Outcome

Chosen option: "Technitium DNS Server (v13+)", because it provides modern native OIDC Single Sign-On with Authentik, packages recursive caching and authoritative DNS into a single lightweight container (~150 MB RAM), requires zero external database dependencies, and exposes a comprehensive HTTP REST API for automated configuration.

### Positive Consequences

- Drastically reduced complexity: replaced 3 containers (`pdns`, `recursor`, `powerdns-admin`) with 1 container (`core-dns`).
- Eliminates external PostgreSQL database dependency for DNS lookups.
- Native OIDC SSO with Authentik via `/sso/callback` with automatic group-to-role mapping.
- High-performance DNS engine supporting modern standards (DNSSEC, DoH, DoT, blocklists).
- Clean, responsive web dashboard with real-time telemetry.

### Negative Consequences

- Requires .NET runtime (packaged in the official Docker image).
- Technitium stores settings in binary application format rather than raw SQL tables; all automated configuration is managed via HTTP REST API.

## Pros and Cons of the Options

### Technitium DNS Server

- Good, because single container with low resource footprint (~150 MB RAM).
- Good, because native OIDC SSO with role and group mapping.
- Good, because unified recursive and authoritative engine.
- Good, because comprehensive REST API for zone and record management.
- Bad, because relies on REST API rather than standard SQL queries for inspection.

### PowerDNS Authoritative Server + PowerDNS-Admin

- Good, because RFC-compliant enterprise C++ engine.
- Bad, because requires 3 separate containers and external database schemas.
- Bad, because higher operational complexity and configuration synchronization friction.

### BIND 9

- Good, because industry standard.
- Bad, because no official web GUI or native SSO integration.
