# Choose Technitium as Authoritative DNS Server

- Status: superseded by [ADR-0016](0016-choose-powerdns-and-powerdns-admin-for-dns.md)
- Date: 2026-11-03

## Context and Problem Statement

We need an internal and authoritative DNS server to manage local domain zones, resolve service hostnames across internal SDN subnets, and provide public DNS record serving for our domains.

The DNS server must support automated programmatic record management via a well-documented HTTP API, handle both authoritative zones and recursive upstream forwarding, and operate reliably in a containerized environment.

## Decision Drivers

- **RESTful HTTP API**: Comprehensive API supporting automated zone creation, record manipulation, and token-based authentication for Ansible automation.
- **Authoritative & Recursive Capabilities**: Ability to serve authoritative internal and external zones while acting as a recursive forwarding resolver.
- **Modern DNS Features**: Built-in support for DNS-over-HTTPS (DoH), DNS-over-TLS (DoT), DNSSEC, and dynamic blocking / sinkholing.
- **User-Friendly Management**: Rich web console for ad-hoc inspection and manual verification by operators.

## Considered Options

- Technitium DNS Server
- BIND 9
- CoreDNS
- PowerDNS
- Pi-hole

## Decision Outcome

Chosen option: "Technitium DNS Server", because it combines a production-grade DNS engine (authoritative, recursive, and forwarding) with an extensive HTTP REST API that integrates seamlessly with Ansible automation, alongside a clean web dashboard for manual administration.

### Positive Consequences

- Clean REST API enables fully automated zone provisioning and record management directly via Ansible URI tasks.
- Single container deployment with low resource usage (~150 MB RAM).
- Built-in support for multiple zone types, secondary zones, and forwarding rules.
- Web dashboard provides clear visibility into query rates, cache hits, and zone configurations.

### Negative Consequences

- Requires .NET runtime (packaged in the official container image).
- Less ubiquitous than BIND 9 in traditional enterprise Unix environments.

## Pros and Cons of the Options

### Technitium DNS Server

- Good, because modern HTTP REST API simplifies infrastructure automation.
- Good, because serves both authoritative zones and recursive/caching DNS.
- Good, because integrated web UI simplifies inspection and debugging.
- Bad, because smaller community compared to legacy BIND 9.

### BIND 9

- Good, because de-facto standard with decades of production usage.
- Bad, because programmatic record automation requires complex `nsupdate` (TSIG keys) or raw zone file templating with daemon reloads.
- Bad, because lacks a native web interface or REST API.

### CoreDNS

- Good, because cloud-native, lightweight, and extensible via Go plugins.
- Bad, because primarily designed for Kubernetes service discovery; managing authoritative records programmatically requires external plugins or GitOps file reload pipelines.
- Bad, because no web UI for manual administrative inspection.

### PowerDNS

- Good, because strong database backends and robust HTTP API.
- Bad, because requires external database (PostgreSQL/MySQL) and separate components for Authoritative and Recursor engines, adding deployment complexity.

### Pi-hole

- Good, because excellent ad-blocking web UI and simple setup.
- Bad, because primarily designed for DNS sinkholing and recursive forwarding; lacks true multi-zone authoritative DNS features and robust record management APIs.
