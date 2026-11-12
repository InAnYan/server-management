# Choose Gatus for Declarative Service Monitoring

- Status: accepted
- Date: 2026-11-12
- Supersedes: [ADR-0006](0006-choose-uptime-kuma-for-monitoring.md)

## Context and Problem Statement

The platform requires an uptime and service health monitoring solution to track the availability, latency, and status of internal services, virtual machines, database ports, and reverse proxy entrypoints.

Previously, Uptime Kuma ([ADR-0006](0006-choose-uptime-kuma-for-monitoring.md)) was selected. However, Uptime Kuma does not support native OpenID Connect (OIDC) Single Sign-On (requiring reverse-proxy header authentication hacks or separate local accounts), and stores monitor definitions in an internal stateful SQLite database rather than declarative configuration files, making GitOps and automated Ansible provisioning cumbersome.

We need a lightweight, developer-friendly health monitoring and status page system that natively supports OIDC Single Sign-On, defines all monitors in declarative configuration files, and integrates cleanly with Ansible.

## Decision Drivers

- **Native SSO / OIDC**: Direct support for OpenID Connect authentication to secure administrative dashboards without reverse-proxy authentication wrappers.
- **Declarative Configuration**: All probe endpoints, intervals, alerting conditions, and status page settings must be declarable in version-controlled YAML files suitable for Ansible templating (`config.yaml.j2`).
- **Multi-Protocol Probing**: Support for HTTP/HTTPS (status code, body regex, latency, certificate expiration), TCP ports, ICMP ping, and DNS queries.
- **Resource Efficiency**: Low memory and CPU footprint suitable for a minimal virtual machine (< 100 MB RAM).
- **Integrated Status Page & Alerting**: Clean public/internal status dashboard with native alert integrations (Telegram, Discord, Slack, email, webhooks).

## Considered Options

- Gatus
- Uptime Kuma (current)
- Prometheus Blackbox Exporter + Grafana
- OneUptime

## Decision Outcome

Chosen option: "Gatus", because it provides native OpenID Connect SSO out of the box, defines all monitoring probes in a single declarative YAML file (making Ansible configuration 100% idempotent and GitOps-native), runs as a single lightweight Go container consuming under 50 MB RAM, and provides a polished, responsive status page.

### Positive Consequences

- All monitors are defined in Git and templated cleanly via Ansible without relying on stateful database mutations or browser GUI clicks.
- Operators log in seamlessly using platform Single Sign-On via Authentik ([ADR-0014](0014-choose-authentik-as-central-identity-provider.md)).
- Minimal compute requirements (< 50 MB RAM, single binary/container).
- Rich probe capabilities including TLS certificate expiry tracking and response time distribution graphs.

### Negative Consequences

- No in-dashboard GUI for dynamically creating monitors at runtime; all monitors must be defined in configuration files and applied via Ansible (which aligns with Infrastructure-as-Code principles).

## Pros and Cons of the Options

### Gatus

- Good, because native OIDC authentication integration with identity providers.
- Good, because 100% declarative YAML configuration enables seamless Ansible automation.
- Good, because ultra-low resource footprint (< 50 MB RAM, written in Go).
- Good, because built-in automated status page and broad alerting channels.
- Bad, because configuration changes require file edits and process reload rather than point-and-click UI creation.

### Uptime Kuma

- Good, because intuitive web UI for manual monitor management.
- Bad, because lacks native OIDC / SSO support in upstream core.
- Bad, because monitor configuration is stored in internal SQLite database, complicating declarative Infrastructure-as-Code workflows.

### Prometheus Blackbox Exporter + Grafana

- Good, because deep metric aggregation and flexible visualization.
- Bad, because does not provide an out-of-the-box public status page with incident history.
- Bad, because higher operational overhead and configuration complexity across multiple components.

### OneUptime

- Good, because comprehensive full-stack observability suite.
- Bad, because requires 8 GB+ RAM and dozens of microservice containers, exceeding coordinator resource budgets.
