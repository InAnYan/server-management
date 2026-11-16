# Choose Valkey as In-Memory Cache Database

- Status: accepted
- Date: 2026-11-05

## Context and Problem Statement

The infrastructure requires a fast, in-memory key-value cache and datastore for session storage, caching, pub/sub messaging, and task queuing across core, development, and production environments. We need to select an in-memory caching engine that provides long-term open-source sustainability, minimal memory overhead, and high throughput.

## Decision Drivers

- **Open Source Governance**: Permissive open-source licensing without restrictive source-available dual licenses or risk of future vendor lock-in.
- **Lightweight Footprint**: Low baseline memory consumption and CPU usage suitable for virtualized, multi-tenant Proxmox environments.
- **Performance & Compatibility**: High-throughput, sub-millisecond latency, and 100% wire-protocol compatibility with standard Redis client libraries.

## Considered Options

- Valkey
- Redis
- Dragonfly
- KeyDB

## Decision Outcome

Chosen option: "Valkey", because it is an open-source (BSD-3-Clause), community-driven project backed by the Linux Foundation and major industry cloud providers (AWS, Google Cloud, Oracle, Ericsson, Snap). It maintains 100% wire and protocol compatibility with the Redis API while guaranteeing perpetual open-source availability, low baseline memory consumption (~10 MB at idle), and sustained high performance.

### Positive Consequences

- **Open Source Freedom**: Licensed under the OSI-approved BSD-3-Clause license, eliminating licensing ambiguity, vendor lock-in, and compliance risks.
- **Drop-in Compatibility**: Fully compatible with existing Redis SDKs, CLI tools (`redis-cli`, `valkey-cli`), and application integrations without requiring code modifications.
- **Resource Efficiency**: Retains the lightweight, event-driven C architecture of Redis, consuming negligible baseline memory and CPU.
- **Multi-Vendor Governance**: Maintained under the Linux Foundation umbrella, ensuring healthy multi-stakeholder governance and continuous updates.

### Negative Consequences

- **Ecosystem Branding Transition**: Requires documenting that the service exposes the Redis protocol and standard port 6379 while running the official `valkey/valkey` container image.

## Pros and Cons of the Options

### Valkey

The community-led, Linux Foundation continuation of the open-source Redis codebase.

- Good, because licensed under the permissive BSD-3-Clause license with neutral foundation governance.
- Good, because 100% wire-compatible with Redis 7.2+ protocols and client libraries.
- Good, because exceptionally lightweight, consuming minimal RAM and idling with virtually zero CPU utilization.
- Good, because highly performant with extensive multi-threaded I/O optimizations in modern releases.

### Redis

The original in-memory data store developed by Redis Ltd.

- Good, because ubiquitous ecosystem recognition and extensive third-party documentation.
- Good, because performant and battle-tested across thousands of enterprise deployments.
- Bad, because relicensed in March 2024 under proprietary dual source-available licenses (RSALv2 and SSPLv1), disqualifying it as open source under OSI definitions.
- Bad, because future versions carry legal and compliance restrictions for hosted services.

### Dragonfly

A modern, multi-threaded in-memory datastore written in C++ designed for multi-core hardware.

- Good, because extremely high throughput and excellent memory density under heavy write loads.
- Good, because provides broad API compatibility with Redis commands.
- Bad, because licensed under the Business Source License (BSL 1.1), which is non-free and restricts commercial usage.
- Bad, because higher baseline memory footprint and complex memory indexing model unnecessary for small-to-medium cache workloads.

### KeyDB

A multi-threaded fork of Redis originally developed by EQ Alpha (acquired by Snap).

- Good, because open source under the BSD license.
- Good, because multi-threaded query execution delivers higher single-node throughput than single-threaded Redis.
- Bad, because project development and community momentum slowed significantly following commercial acquisition.
- Bad, because smaller community compared to the Linux Foundation-backed Valkey initiative.
