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

### Access to the host should be available only via tailscale

req~host-access-tailscale-only~1

Covers:

* feat~infrastructure-security~1

Needs: impl, oman

### Proxmox API keys should have only required permissions

req~proxmox-api-permissions-minimal~1

Covers:

* feat~infrastructure-security~1

Needs: impl

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

Configures administrative and service accounts on Technitium DNS, Uptime Kuma, and Gitea.

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
