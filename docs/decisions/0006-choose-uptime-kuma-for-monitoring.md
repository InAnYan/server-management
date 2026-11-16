# Choose Uptime Kuma for Monitoring

- Status: superseded by [ADR-0015](0015-choose-gatus-for-declarative-service-monitoring.md)
- Date: 2026-11-02

## Context and Problem Statement

We need an infrastructure and service monitoring system to track availability, response times, and health endpoints across internal virtual machines, containerized workloads, database ports, and public HTTPS entrypoints.

The system should provide immediate visibility into infrastructure health, support automated alerting, and offer a clean status page without consuming significant server compute resources.

## Decision Drivers

- **Lightweight Resource Usage**: Minimal CPU and RAM footprint suitable for running in a small coordinator VM (`core-coord-uptimekuma`, 1 GB RAM).
- **Multi-Protocol Probing**: Native support for HTTP(S) keywords/status codes, TCP port checks, DNS lookups, and PostgreSQL connection probes.
- **Built-in Status Page**: Integrated, customizable public status page with incident reporting out of the box.
- **Automated Configuration**: Scriptable configuration via API or Ansible automation modules to register monitors and groups during provisioning.

## Considered Options

- Uptime Kuma
- Prometheus + Grafana + Alertmanager + Blackbox Exporter
- Zabbix
- Gatus

## Decision Outcome

Chosen option: "Uptime Kuma", because it provides a self-contained, lightweight monitoring system with an intuitive web dashboard and status page, requires no external database (using local SQLite), and supports all required probe types (HTTP, TCP, DNS, PostgreSQL) with minimal configuration overhead.

### Positive Consequences

- All-in-one architecture: dashboard, monitoring engine, and status page run in a single container.
- Low memory usage (~80-120 MB RAM).
- Automated provisioning of monitors, groups, and status pages via Ansible and Socket.IO API.
- Broad notification integration (Telegram, Discord, Slack, email, webhooks).

### Negative Consequences

- SQLite database is local to the container; requires scheduled VM backups for persistent history.
- Not designed for high-cardinality time-series metrics or distributed APM tracing (metrics are limited to uptime percentages and latency graphs).

## Pros and Cons of the Options

### Uptime Kuma

- Good, because single container deployment with integrated status page and alerting.
- Good, because supports HTTP, TCP, DNS, and PostgreSQL probe checks natively.
- Good, because lightweight footprint requires minimal hardware allocation.
- Bad, because lacks complex multi-dimensional metric querying found in Prometheus.

### Prometheus + Grafana + Blackbox Exporter

- Good, because powerful metric querying, alerting rules, and flexible dashboarding.
- Bad, because substantial resource consumption and operational complexity (4+ separate containers/daemons).
- Bad, because does not provide an integrated public status page out of the box.

### Zabbix

- Good, because comprehensive enterprise monitoring with agent-based and agentless probes.
- Bad, because heavy architecture requiring a dedicated database backend and complex setup.
- Bad, because excessive overhead for monitoring fewer than 20 services.

### Gatus

- Good, because very lightweight and configured via YAML.
- Bad, because less mature notification ecosystem and lacks interactive web UI management.
