# Choose Authentik as Central Identity Provider

- Status: accepted
- Date: 2026-11-12

## Context and Problem Statement

The infrastructure runs numerous internal administrative dashboards and platform services (Gitea, Grafana, MinIO Console, PowerDNS-Admin, Gatus, Proxmox VE). Managing local credentials, manual account creation, and password rotation independently on every individual service introduces substantial operational overhead, password sprawl, and concentration of static credentials in local configuration files.

We need a self-hosted, centralized Identity Provider (IdP) supporting Single Sign-On (SSO) via standard protocols (OpenID Connect and SAML 2.0), multi-factor authentication (MFA/WebAuthn), fine-grained application access policies, and automated user provisioning via API.

## Decision Drivers

- **Standard Protocols**: First-class support for OpenID Connect (OIDC) and SAML 2.0 to integrate seamlessly with modern cloud-native applications.
- **Granular Access Control**: Ability to restrict access per application using user group bindings and execution policies (e.g. allowing a user to access Gitea while denying access to Grafana or PowerDNS).
- **Modern Authentication & MFA**: Native support for Passkeys (WebAuthn/FIDO2), TOTP, and self-service account recovery.
- **Programmatic Administration**: Full REST API and CLI automation for creating users, service accounts, and group memberships via Ansible.
- **Moderate Footprint**: Capable of running smoothly in a dedicated coordinator VM (`core-coord-authentik`, 2 Cores, 2 GB RAM).

## Considered Options

- Authentik
- Authelia
- Keycloak
- Casdoor

## Decision Outcome

Chosen option: "Authentik", because it provides a complete, modern open-source identity platform combining an OIDC/SAML IdP, built-in application access policies, a sleek user and admin portal, native WebAuthn support, and a comprehensive REST API that integrates cleanly with Ansible.

### Positive Consequences

- Single source of truth for operator identities and permissions across all platform services.
- Eliminates individual `create_*_user.yml` operational playbooks in favor of a single `create_sso_user.yml` playbook.
- Users authenticate once and gain seamless access to authorized services without repeatedly entering passwords.
- Application-level policy enforcement ensures users only access applications explicitly granted to their group.
- Leverages existing `core-data-postgres` and `core-data-redis` infrastructure.

### Negative Consequences

- Higher resource footprint than minimalist auth proxies like Authelia (~600 MB - 1 GB RAM for server + worker).
- Requires PostgreSQL and Redis backend storage.
- External IdP availability becomes a prerequisite for dashboard logins (though SSH and root CLI access remain independent fail-safes).

## Pros and Cons of the Options

### Authentik

- Good, because modern Python/Go architecture with active development and extensive documentation.
- Good, because native OIDC provider and SAML 2.0 service provider/identity provider modes.
- Good, because granular application binding policies allow per-app access restriction.
- Good, because fully automatable via REST API and Python/Ansible.
- Bad, because requires both a web server container and an asynchronous task worker container.

### Authelia

- Good, because extremely lightweight Go binary (< 100 MB RAM).
- Good, because excellent reverse proxy companion.
- Bad, because lacks a comprehensive built-in administrative GUI for managing users, groups, and application bindings dynamically.
- Bad, because user management traditionally relies on static YAML configuration or external LDAP servers (e.g. LLDAP).

### Keycloak

- Good, because enterprise standard with battle-tested security compliance and extensive feature set.
- Bad, because heavy Java/Quarkus runtime consumes 1.5 GB - 2 GB+ RAM at baseline.
- Bad, because significant operational complexity and configuration verbosity unsuitable for a lean single-node infrastructure.

### Casdoor

- Good, because lightweight Go/React architecture with clean user interface.
- Bad, because smaller community and ecosystem adoption compared to Authentik and Keycloak.
- Bad, because application authorization policy engine is less mature than Authentik's flow/policy framework.
