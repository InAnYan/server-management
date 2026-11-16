# Choose Grafana and Loki for Centralized Logging

- Status: accepted
- Date: 2026-11-12

## Context and Problem Statement

As the Proxmox infrastructure grew to encompass over a dozen virtual machines across multiple environments (`core`, `dev`, `prod`) and network tiers (`coord`, `apps`, `data`), troubleshooting issues and maintaining audit compliance required SSHing into individual machines to query `journalctl` or `docker logs`. This approach lacked cross-host correlation, made forensic investigation tedious, and provided no unified visibility into system health or anomalies.

The platform requires a centralized logging architecture that:

1. Ingests systemd journal entries and Docker container logs across all VMs and the hypervisor host near real-time.
2. Imposes minimal memory and CPU overhead on individual workload nodes and the central aggregation node.
3. Provides high-speed querying, filtering, and streaming capabilities.
4. Enforces strict authentication and role-based access controls to safeguard logs against unauthorized inspection.
5. Operates within our private SDN architecture without exposing unauthenticated ingestion endpoints to the public internet.

## Decision Drivers

- **Resource Footprint**: Running on a single-node Proxmox VE hypervisor requires minimizing memory consumption. Workload nodes should not sacrifice substantial RAM to logging agents, and the aggregator must fit comfortably within modest VM resources (1.5–2 GB RAM).
- **Sub-Second Polling & Ingestion**: High-frequency log shipping (1-second polling and flush intervals) to enable near real-time live tailing.
- **Unified Querying & Visualization**: A polished web UI supporting powerful log queries, filtering, aggregation, and live log tailing.
- **Security & Access Control**: Mandatory authentication, disabled public registration, and granular admin/viewer permissions.
- **Operational Simplicity**: Clean deployment via Docker Compose, automated provisioning via Ansible, and minimal maintenance overhead.
- **Storage Efficiency**: Configurable log retention policies and automated pruning without unbounded disk growth.

## Considered Options

- **Option 1: Grafana + Grafana Loki + Fluent Bit**
- **Option 2: Elastic Stack (Elasticsearch / OpenSearch + Logstash / Filebeat + Kibana)**
- **Option 3: Graylog + MongoDB + OpenSearch**
- **Option 4: ClickHouse + Vector + Grafana**

## Decision Outcome

Chosen option: "Option 1: Grafana + Grafana Loki + Fluent Bit", because it provides the optimal balance of ultra-low resource consumption, seamless integration, high-performance indexing, and industry-standard visualization.

Unlike traditional search engines (like Elasticsearch or OpenSearch) that build full-text inverted indexes over every token in every log line—requiring gigabytes of dedicated heap memory—Grafana Loki adopts a metadata-indexing model ("like Prometheus, but for logs"). It indexes only operational labels (`vm`, `unit`, `container_name`, `stream`) while storing compressed log chunks on disk. This results in an order-of-magnitude reduction in memory footprint and storage costs.

Fluent Bit was selected as the universal edge agent because of its lightweight C implementation (~10–20 MB RAM footprint per node), native support for `systemd` journal ingestion and Docker log tailing, and built-in Loki export plugin.

Grafana serves as the visualization and access-control layer, providing rich LogQL querying, live log tailing, dashboard generation, and built-in RBAC behind our Caddy reverse proxy.

### Positive Consequences

- **Minimal Node Overhead**: Fluent Bit consumes under 20 MB of RAM on each VM, making it suitable even for resource-constrained database and coordinator nodes.
- **Low Central Storage & RAM Footprint**: The entire aggregation and visualization stack (`core-coord-logger`) operates reliably with only 1.5 GB of allocated RAM and automated chunk retention pruning (14-day default).
- **Sub-Second Visibility**: Logs are polled and flushed every 1 second, providing near real-time streaming in Grafana's Explore UI.
- **Granular Security Controls**: Public sign-ups are disabled (`GF_USERS_ALLOW_SIGN_UP=false`), anonymous access is prohibited (`GF_AUTH_ANONYMOUS_ENABLED=false`), and user provisioning is automated via Ansible playbooks.
- **Extensibility**: Grafana can natively ingest and correlate Prometheus metrics, Uptime Kuma statuses, and application performance data alongside Loki logs in future iterations.

### Negative Consequences

- **Full-Text Search Latency on Large Datasets**: Because Loki does not build full-text inverted indexes, regex and string searches across massive time ranges require scanning chunk contents, which can be slower than Elasticsearch on multi-terabyte datasets. For our fleet size, this trade-off is well worth the 90%+ RAM savings.
- **LogQL Learning Curve**: Operators must learn LogQL expressions (`{vm="core-coord-caddy"} |= "error" | json`) rather than simple Lucene search syntax.
- **Single-Node Retention Risk**: As documented in the security notices, logs reside on local VM disk within the Proxmox host rather than an external immutable SIEM. (Mitigated by daily Proxmox snapshot backups and optional future S3 chunk shipping).

## Pros and Cons of the Options

### Option 1: Grafana + Grafana Loki + Fluent Bit

Lightweight, label-indexed log aggregation stack purpose-built for cloud-native infrastructure.

- Good, because ultra-low memory footprint (Loki runs under 500 MB RAM; Fluent Bit under 20 MB per VM).
- Good, because metadata label indexing drastically reduces disk usage and indexing overhead.
- Good, because Grafana provides an industry-leading user interface for live tailing, LogQL queries, and alerting.
- Good, because automated retention compaction (`14d`) requires zero manual index management.
- Bad, because brute-force scanning over long unindexed time windows is slower than full-text inverted indexes.

### Option 2: Elastic Stack (Elasticsearch / OpenSearch + Filebeat + Kibana)

The traditional enterprise standard for distributed full-text logging and log analysis.

- Good, because instant full-text search across arbitrary text fields regardless of labels.
- Good, because rich ecosystem of prebuilt parsers and Kibana dashboards.
- Bad, because extremely memory-hungry: Elasticsearch/OpenSearch JVM heap requires a minimum of 4–8 GB of dedicated RAM to operate reliably, exceeding the coordinator tier budget.
- Bad, because complex cluster state, index lifecycle management (ILM), and shard tuning overhead.

### Option 3: Graylog + MongoDB + OpenSearch

Open-source log management platform tailored for sysadmins and security operations.

- Good, because powerful log routing, stream alerting, and pipeline transformations.
- Good, because straightforward UI with built-in permission management.
- Bad, because heavy operational footprint requiring three separate services: Graylog server, MongoDB metadata database, and an OpenSearch/Elasticsearch indexing engine.
- Bad, because high RAM and disk consumption unsuited for our lightweight single-host architecture.

### Option 4: ClickHouse + Vector + Grafana

Columnar database engine paired with a high-throughput Rust-based collector.

- Good, because exceptional analytical query speed and compression ratios over structured tabular logs.
- Good, because Vector is exceptionally fast and memory-safe.
- Bad, because requires designing and managing explicit database schemas, tables, and ingestion pipelines for log events.
- Bad, because higher operational complexity than Loki's zero-schema chunk model.
