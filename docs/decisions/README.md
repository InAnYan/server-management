# Architectural Decision Records (ADRs)

This directory records architectural and operational decisions using the [MADR (Markdown Architectural Decision Records)](https://adr.github.io/madr/) format.

New decisions should be proposed by copying [`template.md`](template.md) into a sequentially numbered file (e.g. `0004-title.md`).

## Decision Index

- [ADR-0000: Use Markdown Architectural Decision Records (MADR)](0000-use-markdown-architectural-decision-records.md)
- [ADR-0001: Use OpenTofu for Provisioning Instead of Terraform](0001-use-opentofu-for-provisioning-instead-of-terraform.md)
- [ADR-0002: Use Tailscale or Similar Mesh Service for Secure Access to Server and Internal Network](0002-use-tailscale-for-secure-access-to-the-server-and-internal-server-network.md)
- [ADR-0003: Use Tailscale for Remote Access](0003-use-tailscale-for-remote-access.md)
- [ADR-0004: Choose Debian Cloud Image for Virtual Machines](0004-choose-debian-cloud-image-for-virtual-machines.md)
- [ADR-0005: Choose Caddy as Ingress Reverse Proxy](0005-choose-caddy-as-reverse-proxy.md)
- [ADR-0006: Choose Uptime Kuma for Monitoring](0006-choose-uptime-kuma-for-monitoring.md)
- [ADR-0007: Choose Technitium as Authoritative DNS Server](0007-choose-technitium-as-authoritative-dns-server.md)
- [ADR-0008: Choose Gitea for Git Repository and Collaboration Platform](0008-choose-gitea-for-git-collaboration.md)
- [ADR-0009: Choose Virtual Machines over LXC Containers](0009-choose-virtual-machines-over-lxc-containers.md)
- [ADR-0010: Choose Valkey as In-Memory Cache Database](0010-choose-valkey-as-in-memory-cache-database.md)
- [ADR-0011: Choose MinIO as S3-Compatible Object Storage](0011-choose-minio-as-s3-compatible-object-storage.md)
- [ADR-0012: Manage Caddy Routing via Modular Configuration Files](0012-manage-caddy-routing-via-modular-configuration-files.md)
- [ADR-0013: Choose Grafana and Loki for Centralized Logging](0013-choose-grafana-and-loki-for-centralized-logging.md)
- [ADR-0014: Choose Authentik as Central Identity Provider](0014-choose-authentik-as-central-identity-provider.md)
- [ADR-0015: Choose Gatus for Declarative Service Monitoring](0015-choose-gatus-for-declarative-service-monitoring.md)
- [ADR-0016: Choose PowerDNS and PowerDNS-Admin for DNS](0016-choose-powerdns-and-powerdns-admin-for-dns.md) (superseded by [ADR-0017](0017-re-adopt-technitium-dns-server.md))
- [ADR-0017: Re-adopt Technitium DNS Server with Native OpenID Connect SSO](0017-re-adopt-technitium-dns-server.md)
