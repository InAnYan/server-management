# Potential Security Issues

## Potential Issues Caused by the Organization

- Unencrypted Terraform secrets
- Unencrypted Ansible secrets
- Devices between networks can freely talk to each other (security is hardened using VNETs and firewall rules, but misconfiguration remains a risk)
- Overflow in IP range or machine ID
- Permissions on how VMs communicate with each other are not granular, but rather generalized in subnetworks
- Backups stored locally on the host via Proxmox storage rather than off-site (host hardware failure destroys both live machines and backups)
- Stateful VMs without external persistence or distributed replication (accidental VM deletion or storage corruption permanently destroys application and database data)
- Single host concentration of responsibilities: the Proxmox host is responsible for too many critical infrastructure roles simultaneously (the Proxmox VE hypervisor itself, host and VM firewall filtering, Tailscale VPN gateway/server, and network router handling inter-subnet routing, SNAT, and Layer 4 socket streaming)
- Non-granular permissions and lack of explicit isolation between Redis / Valkey databases: Redis/Valkey instances using global password authentication grant full read/write access across all database indexes (`0`–`15`) without internal security boundaries between logical DBs; any authenticated client can inspect, modify, or flush keys belonging to other services sharing the instance
- Plaintext storage of Git repository and organization secrets: Gitea Actions secrets (`VM_DEPLOY_SSH_KEY`, `UPTIME_KUMA_ADMIN_PASSWORD`, API tokens) are stored in plaintext in the Gitea PostgreSQL database on VM disk (`core-data-postgres`), exposing deployment credentials if database or disk snapshots are compromised
- Plaintext Docker registry credential persistence on VM disk: when a workload VM authenticates to the internal registry via `docker login`, Docker persists base64-encoded credentials directly in `~/.docker/config.json` without an OS keychain or credential helper daemon
- Permissive or misconfigured Gitea access controls and branch permissions: if repository permissions, branch protection rules, and pull request approval gates are not strictly enforced, an unauthorized or compromised user can push malicious Gitea Actions workflows, Ansible playbooks, or OpenTofu/Terraform configurations that execute with high infrastructure privileges (via CI/CD deployment keys, Atlantis runner, or secret manager tokens) and compromise or break development and production environments
- Broad read-only Infisical machine identity privileges granted to Atlantis bot: granting the Atlantis GitOps automation bot cross-project read-only access to all Infisical projects means that any compromise of Atlantis, unauthorized repository write access, or malicious OpenTofu/Terraform code could read application and infrastructure secrets across all managed environments and projects rather than being strictly restricted to a single project scope
- Centralized logs stored locally on the server without off-site streaming: audit logs and system/container telemetry from all VMs and tiers are aggregated and stored locally on the single Proxmox host (`core-coord-logger`) rather than forwarded to an external SIEM, write-once storage, or off-site logging service; an adversary who compromises the hypervisor or root storage can manipulate, truncate, or wipe forensic logs to conceal intrusions, and host storage destruction permanently obliterates audit history

## General Potential Issues

- Vulnerability in Proxmox
- Weak root password
- Vulnerability in Tailscale
- Weak administrator passwords
- Passwords used for login instead of SSH keys
