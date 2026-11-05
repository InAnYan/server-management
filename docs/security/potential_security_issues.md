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

## General Potential Issues

- Vulnerability in Proxmox
- Weak root password
- Vulnerability in Tailscale
- Weak administrator passwords
- Passwords used for login instead of SSH keys
