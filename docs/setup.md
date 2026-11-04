# Server Setup Guide

Step-by-step instructions to bootstrap a fresh Proxmox VE installation, configure repository access, provision infrastructure with OpenTofu, and deploy all services via Ansible.

## Prerequisites

This guide assumes a freshly installed Proxmox VE server (Debian 12 Bookworm base) accessible via local network or console with the root password configured.

## Phase 1: Host Bootstrap & Preparation

Run these initial commands on the Proxmox host:

1. **Create Primary Administrator Account with Sudo Privileges**:

   ```bash
   adduser ruslan
   usermod -aG sudo ruslan
   ```

2. **Establish Key-Based SSH Access & Disable Password Authentication**:

   <!-- [oman->req~host-access-ssh-keys-only~1] -->
   On your local workstation, copy your public key:

   ```bash
   ssh-copy-id ruslan@<host_lan_ip>
   ```

   On the Proxmox host, enforce public key authentication:

   ```bash
   cat << 'EOF' | sudo tee /etc/ssh/sshd_config.d/01-hardening.conf
   PasswordAuthentication no
   KbdInteractiveAuthentication no
   PermitRootLogin prohibit-password
   PubkeyAuthentication yes
   EOF
   sudo systemctl restart ssh
   ```

3. **Install and Connect Tailscale**:

   <!-- [oman->req~host-access-tailscale-only~1] -->
   Administrative access (SSH and Proxmox Web GUI) is isolated to an encrypted Tailscale network:

   ```bash
   curl -fsSL https://tailscale.com/install.sh | sudo sh
   sudo tailscale up
   ```

4. **Configure Package Repositories and Install Core Tooling**:

   Disable the enterprise subscription repository, enable the free `pve-no-subscription` repository, and install OpenTofu, Ansible, and Git:

   ```bash
   if [ -f /etc/apt/sources.list.d/pve-enterprise.sources ]; then
     sudo sed -i 's/^Enabled: yes/Enabled: no/' /etc/apt/sources.list.d/pve-enterprise.sources
   fi
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-no-subscription.list
   sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
   sudo install -m 0755 -d /etc/apt/keyrings
   curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
   curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
   sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg
   echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
   sudo apt-get update
   sudo apt-get install -y git ansible tofu
   ```

5. **Disable No-Subscription Dialog in Proxmox Web Interface**:

   ```bash
   sudo sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
   sudo systemctl restart pveproxy.service
   cat << 'EOF' | sudo tee /etc/apt/apt.conf.d/no-nag-script
   DPkg::Post-Invoke { "dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ $? -eq 1 ]; then { sed -Ezi.bak \"s/(Ext.Msg.show\\(\\{\\s+title: gettext\\('No valid sub)/void\\(\\{ \\/\\/\\1/g\" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service; }; fi"; };
   EOF
   ```

6. **Create Shared Administration Workspace**:

   All live OpenTofu state and Ansible configurations reside exclusively on the server in `/srv/admin`:

   ```bash
   sudo mkdir -p /srv/admin
   sudo chown root:sudo /srv/admin
   sudo chmod 2770 /srv/admin
   cd /srv/admin
   git clone https://github.com/InAnYan/server-management .
   ```

7. **Bootstrap Secrets & SSH Automation Keypairs**:

   Execute the bootstrap playbook to auto-generate the `id_ansible` and `id_admin` SSH keypairs in `/srv/admin/secrets/` and initialize `/srv/secrets/`:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini playbooks/bootstrap.yml
   ```

8. **Generate Proxmox VE API Token for OpenTofu**:

   <!-- [impl->req~proxmox-api-permissions-minimal~1] -->
   ```bash
   sudo pveum user add terraform-prov@pve -comment "OpenTofu Automation"
   sudo pveum acl modify / -user terraform-prov@pve -role Administrator
   sudo pveum user token add terraform-prov@pve tofu -privsep 0
   ```

   Copy the generated token secret and create `/srv/admin/opentofu/terraform.tfvars`:

   ```bash
   cat << 'EOF' > /srv/admin/opentofu/terraform.tfvars
   proxmox_endpoint  = "https://127.0.0.1:8006/"
   proxmox_insecure  = true
   proxmox_node      = "pve-01"
   proxmox_api_token = "terraform-prov@pve!tofu=YOUR_TOKEN_VALUE"
   EOF
   chmod 0600 /srv/admin/opentofu/terraform.tfvars
   ```

## Phase 2: Provision Infrastructure (OpenTofu)

<!-- [oman->req~provisioning-opentofu~1] -->
Run OpenTofu from `/srv/admin/opentofu` to provision all SDN zones, subnets, resource pools, Debian cloud image, virtual machines, firewalls, and backup jobs:

```bash
cd /srv/admin/opentofu
tofu init
tofu plan
tofu apply
```

This provisions:

- Proxmox SDN zone `local` and virtual networks (`vcoord`, `vcore`, `vcdb`, `vdev`, `vddb`, `vprod`, `vpdb`)
- Debian 12 cloud image
- Virtual machines:
  - `core-coord-caddy` (VMID `1000`, IP `10.10.1.10`)
  - `core-coord-uptimekuma` (VMID `1100`, IP `10.10.1.11`)
  - `core-coord-gitea` (VMID `1200`, IP `10.10.1.12`)
  - `core-app-technitium` (VMID `1500`, IP `10.11.0.10`)
  - `core-data-postgres` (VMID `1900`, IP `10.10.2.10`)
  - `dev-data-postgres` (VMID `2900`, IP `10.20.2.10`)
  - `prod-data-postgres` (VMID `3900`, IP `10.30.2.10`)
- Host and VM firewall rules
- Daily backup jobs

## Phase 3: Configure Services & Workloads (Ansible)

<!-- [oman->req~configuration-ansible~1] -->
Run Ansible to configure all virtual machines, runtimes, applications, and routing:

```bash
cd /srv/admin/ansible
ansible-playbook -i inventory/hosts.ini site.yml
```

The playbook handles:

1. **Baseline**: Essential packages, timezone, journald logging, SSH hardening, and standard user creation (`ansible`, `admin`).
2. **Docker**: Docker CE runtime and Compose plugin on all VM hosts.
3. **PostgreSQL**: Starts database containers across Core, Dev, and Prod instances; initializes superuser passwords, unprivileged probe users, and Gitea database roles.
4. **Technitium DNS**: Creates authoritative zones and A-records (`dns.<zone>`, `status.<zone>`, `git.<zone>`).
5. **Uptime Kuma**: Deploys monitor groups, service endpoints, and status page.
6. **Gitea**: Initializes Git collaboration engine and administrator account.
7. **Caddy Ingress**: Deploys modular reverse proxy configurations and manages TLS certificates.
8. **Host Port Forwarding**: Configures socket streaming for public DNS (port 53) and Git SSH (port 2222).

## Next Steps

Once bootstrap and deployment are complete, refer to the [Usage & Operations Guide](usage.md) for daily administration commands, user provisioning playbooks, and operational runbooks.
