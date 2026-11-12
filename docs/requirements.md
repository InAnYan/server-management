# Infrastructure Requirements

## Server infrastructure should support several environments

feat~multi-environment-support~1

Needs: req

### Server infrastructure should provide isolated Core, Development, and Production environments

req~environments-core-dev-prod~1

Covers:

* feat~multi-environment-support~1

Needs: impl, oman

## Infrastructure should be secure

feat~infrastructure-security~1

Needs: req

### Access to host should be only via ssh keys

req~host-access-ssh-keys-only~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Access to vms should be only via ssh keys

req~vm-access-ssh-keys-only~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### VMs that are database-like should not have access to internet

req~databases-isolated-from-internet~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### VMs from different environment (e.g. dev and prod) should not contact with each other

req~cross-environment-isolation~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Proxmox web dashboard access should be available only via tailscale

req~host-access-tailscale-only~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Host SSH access should be on port 2222 via key-only authentication

req~host-ssh-port-2222-key-only~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Proxmox API keys should have only required permissions

req~proxmox-api-permissions-minimal~1

Covers:

* feat~infrastructure-security~1

Needs: impl

### Proxmox API keys for GitOps should be restricted to target application pools

req~gitops-api-permissions-minimal~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Proxmox API keys should use PVE realm instead of PAM

req~proxmox-api-keys-pve-realm~1

Covers:

* feat~infrastructure-security~1

### Virtual machines should be time synchronized

req~vm-time-synchronization~1

Covers:

* feat~infrastructure-security~1

Needs: impl

### Virtual machines should have regular security updates

req~vm-regular-updates~1

Covers:

* feat~infrastructure-security~1

### Repository should contain workflows and automated checks to detect leaked secrets

req~repository-secret-detection-workflows~1

Covers:

* feat~infrastructure-security~1

Needs: impl

### Git service should require authentication for any actions

req~git-service-private-authentication-required~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### QEMU guest agent execution and file capabilities should be restricted

req~qemu-agent-capabilities-restricted~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### DNS requests should be rate limited

req~dns-requests-rate-limited~1

Covers:

* feat~infrastructure-security~1

### Centralized logging interface should require authentication and prohibit public registration

req~logging-ui-private-authentication-required~1

Enforces strict authentication and disables public user self-registration on the centralized logging web interface, ensuring log streams and audit traces can only be viewed by authenticated operators. Currently implemented via Grafana and Loki ([ADR-0013](decisions/0013-choose-grafana-and-loki-for-centralized-logging.md)).

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Centralized secrets management should manage application secrets and machine identities

req~secrets-management-platform~1

Provides a centralized secrets management vault and automated machine identities for CI/CD runners and GitOps automation. Currently implemented via Infisical ([Secrets Management](security/secrets_management.md)).

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Application container secrets should be mounted ephemerally in RAM

req~in-ram-container-secrets~1

Injects application secrets directly into RAM-backed tmpfs (`/dev/shm`) and mounts them via container secret files (`/run/secrets/`), preventing plaintext secret persistence to physical VM disks.

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

## Infrastructure should be made with infrastructure as code approach

feat~infrastructure-as-code~1

Needs: req

### OpenTofu should be used to provision the infrastructure on proxmox host

req~provisioning-opentofu~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Ansible should be used to configure the host and vms

req~configuration-ansible~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Ansible should be used to create application accounts on apps

req~app-accounts-ansible~1

Configures centralized Single Sign-On (SSO) operator and administrative accounts in Authentik ([ADR-0014](decisions/0014-choose-authentik-as-central-identity-provider.md)), with role and group mappings propagating to platform services (Gitea, Grafana, PowerDNS-Admin, Gatus, MinIO).

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Ansible should be used to configure the reverse proxy

req~reverse-proxy-ansible~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Ansible should be used to configure port forwarding on the host

req~host-port-forwarding-ansible~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Firewall should be enabled

req~firewall-enabled~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Gitea Actions and Atlantis GitOps should be used for automated CI/CD and infrastructure changes

req~gitops-ci-cd-platform~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Reference application template using Python and uv should be provided

req~app-template-python-uv~1

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Centralized logging should collect and retain VM logs

req~centralized-logging~1

Collects systemd journal entries and container logs across all VMs with configurable retention. Currently implemented via Grafana Loki and Fluent Bit ([ADR-0013](decisions/0013-choose-grafana-and-loki-for-centralized-logging.md)).

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Infrastructure should monitor uptime and health of internal services

req~service-uptime-monitoring~1

Continuously monitors HTTP and TCP endpoints for internal platform services and workloads. Currently implemented via Gatus ([ADR-0015](decisions/0015-choose-gatus-for-declarative-service-monitoring.md), superseding [ADR-0006](decisions/0006-choose-uptime-kuma-for-monitoring.md)).

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Platform should provide S3-compatible object storage

req~object-storage-service~1

Provides S3-compatible object storage for application assets, CI/CD artifacts, and VM backups with bucket-level user policy isolation. Currently implemented via MinIO ([ADR-0011](decisions/0011-choose-minio-as-s3-compatible-object-storage.md)).

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Platform should provide in-memory key-value caching

req~in-memory-cache-service~1

Provides dedicated in-memory key-value caching across environment tiers with password authentication. Currently implemented via Valkey / Redis ([ADR-0010](decisions/0010-choose-valkey-as-in-memory-cache-database.md)).

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

### Optional service workloads should be toggleable via boolean feature flags

req~feature-flags-optional-services~1

Allows auxiliary and optional service workloads (such as DNS, object storage, and in-memory caches) to be conditionally provisioned or deprovisioned across environments without breaking infrastructure automation.

Covers:

* feat~infrastructure-as-code~1

Needs: impl, oman

## Stateful VMs should be backed up

feat~stateful-vm-backups~1

Needs: req

### OpenTofu is used to create backups

req~backups-opentofu~1

Covers:

* feat~stateful-vm-backups~1

Needs: impl, oman

## Secrets rotation in the infrastructure should be easily (to the possible extent)

feat~secrets-rotation~1

Needs: req

### A secrets rotation plan should be described

req~secrets-rotation-plan-described~1

Covers:

* feat~secrets-rotation~1

Needs: impl

### Secret rotation should be possible to perform via Ansible

req~secrets-rotation-ansible~1

Covers:

* feat~secrets-rotation~1

Needs: impl, oman
