# Choose PowerDNS and PowerDNS-Admin for DNS

- Status: superseded by [ADR-0017](0017-re-adopt-technitium-dns-server.md)
- Date: 2026-11-12
- Supersedes: [ADR-0007](0007-choose-technitium-as-authoritative-dns-server.md)

## Context and Problem Statement

The platform requires an authoritative and recursive DNS service to manage the primary domain zone, provide local network name resolution, and expose an administrative interface for zone management.

Previously, Technitium DNS Server ([ADR-0007](0007-choose-technitium-as-authoritative-dns-server.md)) was selected. However, Technitium DNS relies on local application user accounts and proprietary API tokens, offering no native OpenID Connect (OIDC) or SAML Single Sign-On. Furthermore, automated record provisioning required ad-hoc HTTP API calls rather than official Ansible collection modules.

We need an industry-standard authoritative DNS server and modern management console that supports native OIDC SSO, integrates with our relational database cluster, and is manageable via official Ansible modules.

## Decision Drivers

- **Native SSO / OIDC**: Direct support for OpenID Connect and SAML 2.0 with role-based access control (RBAC) and group-to-role mapping.
- **First-Class Ansible Support**: Official Ansible collection modules (`community.general.powerdns_*`) for declarative zone and record management.
- **Relational Database Backend**: Integration with PostgreSQL (`core-data-postgres`) for resilient, highly available zone storage and automated database backups.
- **Standards Compliance & Performance**: RFC-compliant authoritative DNS engine capable of DNSSEC, high query throughput, and zone replication.

## Considered Options

- PowerDNS Authoritative Server + PowerDNS-Admin
- Technitium DNS Server (current)
- BIND 9
- CoreDNS

## Decision Outcome

Chosen option: "PowerDNS Authoritative Server + PowerDNS-Admin", because PowerDNS is an enterprise-grade C++ authoritative DNS server backed by PostgreSQL, while PowerDNS-Admin provides a modern web interface with native OpenID Connect SSO, RBAC group mapping, and full REST API compatibility with official Ansible collection modules.

### Positive Consequences

- Seamless Single Sign-On via Authentik ([ADR-0014](0014-choose-authentik-as-central-identity-provider.md)) with automatic administrator group mapping.
- Zone and record data are stored securely in `core-data-postgres`, benefiting from existing daily backup schedules and database replication.
- First-class Ansible automation using `community.general.powerdns_zone` and `community.general.powerdns_record`.
- High query performance and enterprise-proven DNSSEC support.

### Negative Consequences

- Architecture consists of two separate components: the PowerDNS authoritative daemon and the PowerDNS-Admin web application container.
- Depends on the core PostgreSQL cluster for record lookups (already available and highly available on `core-data-postgres`).

## Pros and Cons of the Options

### PowerDNS Authoritative Server + PowerDNS-Admin

- Good, because native OIDC and SAML 2.0 authentication with role and group mapping.
- Good, because supported by official Ansible collection modules.
- Good, because native PostgreSQL storage backend aligns with cluster database standards.
- Good, because battle-tested, high-performance authoritative DNS engine.
- Bad, because two distinct components (DNS engine + web UI) to manage via Docker Compose.

### Technitium DNS Server

- Good, because single all-in-one .NET service.
- Bad, because lacks native OIDC/SAML Single Sign-On.
- Bad, because requires custom Ansible REST API scraping tasks rather than standard Ansible modules.

### BIND 9

- Good, because the reference standard for DNS.
- Bad, because no official web management console or native SSO interface.
- Bad, because flat-file zone configuration requires zone reloads rather than dynamic database persistence.

### CoreDNS

- Good, because lightweight, fast, and modular Go DNS server.
- Bad, because lacks an administrative web UI for interactive inspection and zone editing.
