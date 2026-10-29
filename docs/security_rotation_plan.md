# Security Rotation Plan

Periodic credential and key rotation procedure for the Proxmox VE server and management infrastructure.

---

## Rotation Steps

### 1. Change Root Password

Update the host root account password directly on the Proxmox server:

```bash
sudo passwd root
```

### 2. Change Administrator Passwords

Update system passwords for all administrator user accounts:

```bash
sudo passwd <admin_user>
```

If administrator credentials are used in Ansible automation, update the corresponding local plaintext secret:

```bash
# Update local secret file (gitignored)
$EDITOR /srv/admin/ansible/group_vars/all/secrets.yml
```

### 3. Change Administrator SSH Keys

1. Generate a new key pair on the administrator workstation:

   ```bash
   ssh-keygen -t ed25519 -C "admin-$(date +%Y%m)"
   ```

2. Append the new public key to `~/.ssh/authorized_keys` on the server:

   ```bash
   ssh-copy-id -i ~/.ssh/new_key.pub <admin_user>@<server>
   ```

3. Open a new terminal window to verify key-based access before proceeding.
4. Remove the deprecated public key entry from `~/.ssh/authorized_keys` on the server.

### 4. Change Proxmox API Key

1. **Generate New Token**:
   - In Proxmox Web GUI: **Datacenter** $\rightarrow$ **Permissions** $\rightarrow$ **API Tokens** $\rightarrow$ **Add**.
   - Create a new token ID (e.g. `terraform-v2`) or re-generate the secret.
   - Ensure *Privilege Separation* is unchecked.
   - Copy the new secret UUID immediately.

2. **Update Local Secrets**:
   Update the token in untracked local configurations on the server (`/srv/admin/`) and operator workstations:

   ```bash
   # Update .env
   $EDITOR /srv/admin/.env

   # Update OpenTofu stack variables
   $EDITOR /srv/admin/terraform/server_setup/terraform.tfvars
   $EDITOR /srv/admin/terraform/core_infrastructure/terraform.tfvars
   $EDITOR /srv/admin/terraform/uptime-kuma/terraform.tfvars
   ```

3. **Verify Connectivity**:
   Test that OpenTofu authenticates with the new token:

   ```bash
   cd /srv/admin/terraform/server_setup
   tofu plan
   ```

4. **Revoke Old Token**:
   Once verified, delete the old API token in the Proxmox GUI (**Datacenter** $\rightarrow$ **Permissions** $\rightarrow$ **API Tokens** $\rightarrow$ **Remove**).
