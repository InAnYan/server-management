# Server Setup Guide

Initial Proxmox VE server bootstrap and administration environment setup.

1. Install Proxmox VE
2. Set strong root password
3. Create administrator account with sudo
4. Establish SSH key connection
5. Disable SSH password authentication
6. Setup and connect Tailscale:

   ```bash
   curl -fsSL https://tailscale.com/install.sh | sudo sh
   sudo tailscale up
   ```

7. Configure package repositories and install core tools:

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

8. Disable Proxmox no-subscription notification:

   ```bash
   sudo sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
   sudo systemctl restart pveproxy.service
   cat << 'EOF' | sudo tee /etc/apt/apt.conf.d/no-nag-script
   DPkg::Post-Invoke { "dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ $? -eq 1 ]; then { sed -Ezi.bak \"s/(Ext.Msg.show\\(\\{\\s+title: gettext\\('No valid sub)/void\\(\\{ \\/\\/\\1/g\" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service; }; fi"; };
   EOF
   ```

9. Setup shared administration workspace:

   ```bash
   sudo mkdir -p /srv/admin
   sudo chown root:sudo /srv/admin
   sudo chmod 2770 /srv/admin
   cd /srv/admin
   git clone https://github.com/InAnYan/server-management .
   chmod 660 /srv/admin/.env /srv/admin/terraform/*/*.tfvars 2>/dev/null || true
   ```

10. Generate Ed25519 SSH keys (`id_ansible` and `id_admin`) and place them in the gitignored `secrets/` directory.
