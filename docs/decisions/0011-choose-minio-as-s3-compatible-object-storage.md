# Choose MinIO as S3-Compatible Object Storage

- Status: draft
- Date: 2026-11-05

## Context and Problem Statement

The infrastructure requires an S3-compatible object storage solution for hosting backups, application media, CI/CD pipeline artifacts, and unstructured object blobs across internal environments.

## Decision Drivers

- S3 API standard compliance and compatibility with common SDKs and tooling (`aws-cli`, `mc`, Boto3, Go S3)
- Lightweight deployment model suitable for containerized orchestration via Docker Compose
- Granular bucket management, user identity management, and policy enforcement via CLI and API
- Local single-node deployment capability with minimal operational overhead

## Considered Options

- MinIO

## Decision Outcome

Chosen option: "MinIO", because it is the industry standard for on-premises S3-compatible object storage. It offers high performance, comprehensive S3 API compatibility, a built-in administrative web console, and the powerful MinIO Client (`mc`) tool for programmatic bucket and policy automation.

### Positive Consequences

- **Native S3 Compatibility**: Seamless integration with any tool, application, or backup script that targets AWS S3.
- **Granular Security Controls**: Support for per-bucket user policies, enabling creation of dedicated service accounts restricted strictly to single buckets.
- **Embedded Web Console**: Provides an interactive browser UI for manual object inspection and bucket administrative tasks behind Caddy reverse proxy.
- **Automated Provisioning**: Configurable via standard Docker Compose and scripted via `mc` CLI commands in Ansible playbooks.

### Negative Consequences

- **AGPLv3 Licensing**: Requires careful compliance consideration if redistributing modified source code, though running untouched containers internally is compliant.
- **Resource Footprint**: Consumes more baseline RAM than minimal key-value stores due to Go runtime and metadata indexing structures.

## Pros and Cons of the Options

### MinIO

High-performance, Kubernetes-native, S3-compatible object storage suite.

- Good, because 100% compliant with standard S3 API v4 signatures and operations.
- Good, because includes the MinIO Client (`mc`) for automated user and bucket policy provisioning.
- Good, because provides a responsive web management console out of the box.
- Bad, because strict memory reservation recommendations for multi-terabyte production deployments.
