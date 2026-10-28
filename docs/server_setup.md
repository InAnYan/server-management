# Server Setup Guide

A concise guide for initial Proxmox VE server installation, hardening, and package setup.

---

## 1. Install Proxmox VE

1. Download the Proxmox VE ISO from the official website.
2. Flash the ISO to a USB drive (e.g. using BalenaEtcher or `dd`).
3. Boot the target server from the USB drive and run the installer.
4. Select the target disk (ZFS RAID recommended for multiple disks).
5. Configure static network settings: FQDN, static IP, netmask, gateway, and DNS.
6. Complete installation and reboot. Remove the installation media.

## 2. Set Strong Root Password

Set during installation, or update immediately after first boot:

```bash
passwd root
```

## 3. Create Administrator Account with Sudo

```bash
# Install sudo if not present
apt update && apt install -y sudo

# Create user
adduser admin

# Add user to sudo group
usermod -aG sudo admin
```

## 4. Establish SSH Key Connection

From your local management workstation:

```bash
# Generate key if you don't already have one
ssh-keygen -t ed25519 -C "admin@workstation"

# Copy public key to the server
ssh-copy-id admin@<SERVER_IP>

# Test connection
ssh admin@<SERVER_IP>
```

## 5. Disable SSH Password Authentication

On the server, create a drop-in SSH configuration:

```bash
cat << 'EOF' | sudo tee /etc/ssh/sshd_config.d/01-hardening.conf
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF

# Validate syntax and restart SSH daemon
sudo sshd -t && sudo systemctl restart ssh
```

> [!WARNING]
> Keep your current SSH session open while testing key-based access in a new terminal window to prevent lockout.

## 6. Setup and Connect Tailscale

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sudo sh

# Start Tailscale and authenticate
sudo tailscale up

# Verify connection
tailscale ip -4
tailscale status
```

## 7. Configure Package Repositories and Install Core Tools

Install the Proxmox no-subscription repository and essential tools (`git`, `ansible`, `tofu`):

```bash
# Disable enterprise repo (Proxmox 8 / Bookworm)
if [ -f /etc/apt/sources.list.d/pve-enterprise.sources ]; then
  sudo sed -i 's/^Enabled: yes/Enabled: no/' /etc/apt/sources.list.d/pve-enterprise.sources
fi

# Enable Proxmox no-subscription repository
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-no-subscription.list

# Add OpenTofu official APT repository
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg

echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null

# Install core packages
sudo apt-get update
sudo apt-get install -y git ansible tofu
```

## 8. Disable Proxmox No-Subscription Notification

Silence the popup modal (*"You do not have a valid subscription for this server"*) when opening the Proxmox Web GUI:

```bash
# Patch proxmoxlib.js in place
sudo sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

# Restart the web management daemon
sudo systemctl restart pveproxy.service

# Persist the patch across future package updates via APT hook
cat << 'EOF' | sudo tee /etc/apt/apt.conf.d/no-nag-script
DPkg::Post-Invoke { "dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ $? -eq 1 ]; then { sed -Ezi.bak \"s/(Ext.Msg.show\\(\\{\\s+title: gettext\\('No valid sub)/void\\(\\{ \\/\\/\\1/g\" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service; }; fi"; };
EOF
```

## 9. Setup Shared Administrator Workspace

Create the shared `/srv/admin` workspace owned by `root:sudo` with `2770` permissions (setgid ensures all newly created files inherit the `sudo` group; read/write/execute for root and sudo members, zero access for outsiders):

```bash
# Create shared directory
sudo mkdir -p /srv/admin

# Set ownership to root and sudo group
sudo chown root:sudo /srv/admin

# Set permissions: rwxrwx--- with setgid (2770)
sudo chmod 2770 /srv/admin

# Clone repository into admin workspace
cd /srv/admin
git clone https://github.com/InAnYan/server-management .

# Configure secret files for sudo group access:
# Any local uncommitted secret files must be owned by :sudo and set to 660:
chmod 660 /srv/admin/.env /srv/admin/terraform/*/*.tfvars 2>/dev/null || true
```
