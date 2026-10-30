# Potential Security Issues

## Potential Issues Caused by the Organization

- Unencrypted Terraform secrets
- Unencrypted Ansible secrets
- Devices between networks can freely talk to each other (security is hardened using VNETs and firewall rules, but misconfiguration remains a risk)
- Overflow in IP range or machine ID
- Permissions on how VMs communicate with each other are not granular, but rather generalized in subnetworks

## General Potential Issues

- Vulnerability in Proxmox
- Weak root password
- Vulnerability in Tailscale
- Weak administrator passwords
- Passwords used for login instead of SSH keys
