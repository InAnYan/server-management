# Server Setup Guide

A concise guide for initial Proxmox VE server installation and hardening.

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

## 7. Setup Shared Administrator Workspace

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
