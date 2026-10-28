# Potential Security Issues: Plaintext Secrets in Working Directory

This document analyzes the security risks and attack vectors associated with storing infrastructure secrets in **unencrypted plaintext** on the local management machine (rather than in an encrypted vault like Ansible Vault, SOPS, or HashiCorp Vault), along with the safeguards implemented in this repository.

---

## Architecture Context

In this repository setup:
- **OpenTofu / Terraform variables** (`terraform/vms/terraform.tfvars`, `terraform/uptime-kuma/terraform.tfvars`, and `.env`) are kept locally in plaintext.
- **Ansible secrets** (`ansible/group_vars/all/secrets.yml` or `vault.yml`) are kept locally in plaintext.
- **Git protection**: These files are never committed to version control; they are guarded by `.gitignore`, a Git pre-commit hook, and CI/CD secret detection pipelines.

While this approach significantly simplifies local development and automation (no vault password management, transparent diffs, direct readability), storing plaintext secrets on disk introduces distinct vulnerabilities.

---

## 1. Issue: OpenTofu / Terraform `tfvars` Stored Unencrypted in Plain Text

### Description
Proxmox VE API credentials (API tokens with secret UUIDs, endpoint URLs, user credentials) and VM initial passwords reside in unencrypted `*.tfvars` files and `.env` on the local filesystem.

### Potential Security Risks & Threat Scenarios

1. **Local Machine / Host Compromise**:
   - If the operator's workstation is infected with malware, accessed via unauthorized physical access, or compromised via a supply chain attack (e.g., malicious npm/pip/homebrew package), the attacker gains immediate access to the Proxmox cluster with the privileges of the API token.
   - Proxmox API tokens often possess elevated hypervisor permissions (creating/destroying VMs, accessing VNC consoles, reading storage volumes).

2. **Accidental Git Staging & Leaks**:
   - A developer using force-add (`git add -f`), broad shell globs, or misconfigured IDE Git integration can accidentally bypass `.gitignore` and push `terraform.tfvars` or `.env` to a remote repository.
   - Once pushed to a remote (even if quickly reverted), secrets persist in Git history, reflogs, and pull request caches, requiring immediate token revocation and rotation.

3. **Plaintext State Files (`*.tfstate`)**:
   - OpenTofu stores all resolved resource parameters (including tokens and passwords passed to cloud-init or Proxmox resources) in plaintext in `terraform.tfstate`.
   - Storing both `tfvars` and `tfstate` locally without disk-level encryption increases exposure surfaces.

4. **Unencrypted Backups & Cloud Syncing**:
   - If the repository folder is synchronized via cloud storage (Dropbox, Google Drive, iCloud, OneDrive) or backed up via unencrypted backup solutions (rsync, external USB drives), credentials are copied offsite in plaintext.

### Safeguards & Mitigations in Place
- **Automated Scanning**: GitHub Actions and GitLab CI fail immediately if `*.tfvars` or Proxmox tokens are detected in commits.
- **Pre-commit Hook**: Blocks commits containing `*.tfvars`, `*.tfstate`, or `.env` files before they leave the local staging area.
- **Strict `.gitignore`**: All `*.tfvars`, `*.tfstate`, and `.env*` are excluded by default.
- **Least Privilege Tokens**: Proxmox API tokens should be scoped strictly to the required VMs/pools rather than `Administrator` role on `/`.
- **Workstation Encryption**: The workstation filesystem must use Full Disk Encryption (macOS FileVault or Linux LUKS).
- **Strict File Permissions**: Ensure `chmod 600` on any `*.tfvars` and `.env` files.

---

## 2. Issue: Ansible Secrets Stored Unencrypted in Plain Text

### Description
Host credentials, administrator passwords, service tokens, and SSH configurations are stored in plaintext YAML files (e.g., `ansible/group_vars/all/secrets.yml`) on the local management machine.

### Potential Security Risks & Threat Scenarios

1. **Widespread Lateral Movement**:
   - Ansible variables often hold root/sudo passwords, SSH private keys, database master credentials, or API keys for multiple provisioned nodes.
   - Compromise of `ansible/group_vars/all/secrets.yml` exposes every server managed by the playbook simultaneously, allowing an attacker to move laterally across the entire network.

2. **Accidental Exposure in Command Logs & Diffs**:
   - Running Ansible playbooks without `no_log: true` on tasks that manipulate plaintext variables causes passwords and tokens to be printed directly into stdout, terminal logs, CI logs, or `/var/log/ansible.log`.
   - Using command-line overrides (`-e @secrets.yml`) or running verbose flags (`-vvv`) can expose credentials in process lists (`ps aux`) or terminal scrollback history.

3. **Multi-User / Shared Workstation Exposure**:
   - If the management repository is located on a shared server, jump host, or bastion where multiple operators have local user accounts, unencrypted YAML files are readable by other users unless file permissions (`chmod 600`) are strictly maintained.

4. **Lack of Access Audit Trail**:
   - Unlike secrets managers (e.g., HashiCorp Vault, AWS Secrets Manager, 1Password CLI) that produce cryptographic access logs and handle automatic secret rotation, plaintext files offer no auditing of who read or copied the credentials.

### Safeguards & Mitigations in Place
- **Pre-commit Hook**: Actively scans staged files for `secrets.yml`, `vault.yml`, and common password patterns.
- **Repository Isolation**: Git ignores `ansible/**/secrets.yml` and `ansible/**/vault.yml`. Only sanitized `.example` templates are tracked.
- **Task-Level Masking**: All Ansible tasks dealing with sensitive variables must include `no_log: true`.
- **Key-Based Authentication**: Rely on SSH key pairs with passphrases and `ssh-agent` rather than storing root passwords in plaintext YAML wherever possible.

---

## Summary Comparison Matrix

| Aspect | Encrypted (Vault / SOPS) | Plaintext Local (Current Approach) |
| :--- | :--- | :--- |
| **Commit to Git** | Safe (AES-256 encrypted) | **FORBIDDEN** (Guarded by Hooks & CI/CD) |
| **Ease of Local Use** | Requires vault password / keys | Zero friction, directly editable |
| **Diffs & Code Review** | Ciphertext only; requires tooling | Clear text diffs locally |
| **Workstation Compromise Impact** | Attacker still needs vault passphrase | Attacker gets immediate plaintext secrets |
| **Backup Risk** | Low (cipher remains secure) | High (plaintext copied to backup target) |
| **Operational Guardrails** | Built-in cryptographic protection | Relies on `.gitignore`, pre-commit hook, and CI |
