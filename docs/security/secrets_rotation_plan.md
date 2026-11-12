# Secrets Rotation Plan

<!-- [impl->req~secrets-rotation-plan-described~1] -->
This document outlines the operational procedures for managing and rotating credentials and administrative accounts across the infrastructure.

## Credential Storage Policy

All persistent administrative credentials reside strictly on the host in `/srv/admin/secrets/` with mode `0700` (`ruslan:sudo`) and individual secret files set to `0600`:

- `/srv/admin/secrets/postgres_admin_password`: Core PostgreSQL superuser password
- `/srv/admin/secrets/dev_postgres_admin_password`: Development PostgreSQL superuser password
- `/srv/admin/secrets/prod_postgres_admin_password`: Production PostgreSQL superuser password
- `/srv/admin/secrets/dns_admin_password`: Technitium DNS Server administrative password
- `/srv/admin/secrets/authentik_secret_key`: Authentik cryptographic secret key for signing tokens and sessions
- `/srv/admin/secrets/authentik_db_password`: Dedicated PostgreSQL database role password for Authentik
- `/srv/admin/secrets/authentik_bootstrap_token`: Bootstrap API token for automated Authentik provisioning
- `/srv/admin/secrets/authentik_admin_password`: Root administrator account password for Authentik
- `/srv/admin/secrets/gitea_admin_password`: Gitea administrator account password
- `/srv/admin/secrets/gitea_db_password`: Gitea dedicated PostgreSQL database role password
- `/srv/admin/secrets/redis_core_password`: Core Valkey / Redis shared access password
- `/srv/admin/secrets/redis_dev_password`: Development Valkey / Redis shared access password
- `/srv/admin/secrets/redis_prod_password`: Production Valkey / Redis shared access password
- `/srv/admin/secrets/minio_admin_password`: MinIO S3 root administrative credentials password
- `/srv/admin/secrets/atlantis_proxmox_token`: Scoped Proxmox VE API token for Atlantis GitOps (`atlantis-prov@pve!tofu`)
- `/srv/admin/secrets/atlantis_webhook_secret`: Shared HMAC secret for Atlantis Gitea webhooks
- `/srv/admin/secrets/gitea_utility_password`: Gitea utility bot user password
- `/srv/admin/secrets/gitea_utility_token`: Scoped API token (`repo,package`) for Atlantis and container registry
- `/srv/admin/secrets/gitea_runner_token`: Gitea Actions Act Runner registration token
- `/srv/admin/secrets/infisical_admin_password`: Infisical root administrator account password
- `/srv/admin/secrets/infisical_db_password`: Dedicated PostgreSQL database role password for Infisical
- `/srv/admin/secrets/infisical_encryption_key`: 16-byte hex encryption key used by Infisical for data at rest
- `/srv/admin/secrets/infisical_auth_secret`: Cryptographic secret for signing Infisical JWTs and sessions

Coordinator and application containers receive credentials via environment variables or API calls at runtime. PostgreSQL instances store `POSTGRES_PASSWORD` in `/opt/postgres/docker-compose.yml` (strictly protected with `0600 root:root` permissions) to satisfy initial database bootstrap.

## Automated Admin Password Rotation (Ingress Isolation)

<!-- [oman->req~secrets-rotation-ansible~1] -->
To rotate admin passwords safely without exposing services to unauthenticated public requests during credential transitions, use the automated rotation playbook:

```bash
cd /srv/admin/ansible
ansible-playbook -i inventory/hosts.ini playbooks/ops/rotate_admin_passwords.yml
```

### Rotation Lifecycle

1. **Ingress Isolation**: Caddy immediately switches public routes to maintenance mode, serving HTTP 503 to external traffic during credential changes if required.
2. **PostgreSQL Rotation**: The superuser password is reset directly over local Unix domain socket inside `core-data-postgres` via `ALTER ROLE`.
3. **Authentik Admin Rotation**: Generates a fresh random password, updates `/srv/admin/secrets/authentik_admin_password`, and invokes Authentik REST API to update the `akadmin` account password.
4. **Ingress Restoration**: Caddy reloads with normal reverse proxy routing, restoring public access.

## Provisioning Centralized SSO User Accounts

<!-- [oman->req~app-accounts-ansible~1] -->
User identity and permissions are managed centrally through Authentik Single Sign-On (SSO). To provision user accounts (both administrators and regular operators) across the entire platform without managing separate per-application credentials:

```bash
cd /srv/admin/ansible

# Provision standard user
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_sso_user.yml \
  -e "username=developer" \
  -e "email=developer@example.com" \
  -e "password=DevSecretPassword123!" \
  -e "groups_list=['users']"

# Provision platform administrator (member of authentik Admins)
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_sso_user.yml \
  -e "username=ruslan" \
  -e "email=ruslan@example.com" \
  -e "password=AdminSecretPassword123!" \
  -e "groups_list=['admins']"
```

## Manual Service-Specific Procedures

### PostgreSQL Superuser Password

1. Write the new secret to the appropriate secret file (e.g. `postgres_admin_password`, `dev_postgres_admin_password`, or `prod_postgres_admin_password`):

   ```bash
   openssl rand -base64 24 > /srv/admin/secrets/postgres_admin_password
   chmod 600 /srv/admin/secrets/postgres_admin_password
   ```

2. Apply the change via local container socket on the respective database host:

   - **Core (`core-data-postgres`, `10.10.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.10.2.10 \
       "docker exec -i core-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/admin/secrets/postgres_admin_password)';\""
     ```

   - **Dev (`dev-data-postgres`, `10.20.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.20.2.10 \
       "docker exec -i dev-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/admin/secrets/dev_postgres_admin_password)';\""
     ```

   - **Prod (`prod-data-postgres`, `10.30.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.30.2.10 \
       "docker exec -i prod-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/admin/secrets/prod_postgres_admin_password)';\""
     ```

3. Update the corresponding group variables if maintaining static overrides: `ansible/group_vars/core_databases.yml`, `ansible/group_vars/dev_databases.yml`, or `ansible/group_vars/prod_databases.yml`.

### Authentik Administrator Password

1. Generate a new password and store in `/srv/admin/secrets/authentik_admin_password`:

   ```bash
   cp /srv/admin/secrets/authentik_admin_password /srv/admin/secrets/authentik_admin_password.old
   openssl rand -base64 24 > /srv/admin/secrets/authentik_admin_password
   chmod 600 /srv/admin/secrets/authentik_admin_password*
   ```

2. Execute the password update via Authentik REST API using the bootstrap token:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini playbooks/ops/rotate_admin_passwords.yml
   ```

### Technitium DNS Administrator Password

1. Generate a new administrator password:

   ```bash
   openssl rand -base64 24 > /srv/admin/secrets/dns_admin_password
   chmod 600 /srv/admin/secrets/dns_admin_password
   ```

2. Re-apply the DNS role to reload the service container:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory site.yml --tags dns
   ```

### Atlantis Proxmox VE API Token

The Atlantis Proxmox API token (`atlantis-prov@pve!tofu`) allows Atlantis to manage VMs only within `/pool/dev-app` and `/pool/prod-app`.

Rotation requires updating the token first on the Proxmox host, then deploying it to the Gitea VM:

1. **Host-Side Token Recreation (Proxmox VE)**:
   Delete the old token and generate a fresh token on the Proxmox host:

   ```bash
   # Remove old token from Proxmox
   pveum user token delete atlantis-prov@pve tofu

   # Generate new token
   NEW_TOKEN=$(pvesh create /access/users/atlantis-prov@pve/token/tofu --privsep 0 --output-format json | jq -r .value)

   # Store on host with required qualified prefix
   echo -n "atlantis-prov@pve!tofu=${NEW_TOKEN}" | sudo tee /srv/admin/secrets/atlantis_proxmox_token > /dev/null
   sudo chmod 0600 /srv/admin/secrets/atlantis_proxmox_token
   sudo chown ruslan:sudo /srv/admin/secrets/atlantis_proxmox_token
   ```

2. **VM-Side Application (Gitea Coordinator VM)**:
   Deploy the updated secret into the Atlantis container environment:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini site.yml --tags gitea
   ```

   This task updates `PROXMOX_VE_API_TOKEN` in `/srv/gitea/docker-compose.yml` on `core-coord-gitea` and recreates the `core-gitea-atlantis` container.

3. **Validation**:
   Verify Atlantis can reach Proxmox API with the rotated token:

   ```bash
   ssh -i /srv/admin/secrets/id_ansible ansible@10.10.1.12 \
     'docker exec core-gitea-atlantis curl -k -s -H "Authorization: PVEAPIToken=$(docker exec core-gitea-atlantis printenv PROXMOX_VE_API_TOKEN)" https://10.10.1.1:8006/api2/json/version'
   ```

### Gitea Utility Bot Account Password

The `utility` user is the dedicated service account for CI/CD automation, registry pushes, and Atlantis integration.

1. **Host-Side Password Generation**:
   Generate a new password on the administration host:

   ```bash
   openssl rand -base64 24 | tr -d '\n' | sudo tee /srv/admin/secrets/gitea_utility_password > /dev/null
   sudo chmod 0600 /srv/admin/secrets/gitea_utility_password
   sudo chown ruslan:sudo /srv/admin/secrets/gitea_utility_password
   ```

2. **VM-Side Account Update**:
   Update the password in Gitea's internal user database on `core-coord-gitea`:

   ```bash
   NEW_PASS=$(sudo cat /srv/admin/secrets/gitea_utility_password)
   ssh -i /srv/admin/secrets/id_ansible ansible@10.10.1.12 \
     "docker exec -u git core-gitea gitea admin user change-password --username utility --password '${NEW_PASS}' -c /data/gitea/conf/app.ini"
   ```

### Gitea Utility Docker Registry & Atlantis Access Token

The utility personal access token (`/srv/admin/secrets/gitea_utility_token`) has scoped access (`repo,package`) used by Atlantis to interact with PRs and by CI runners to authenticate to the Gitea container registry.

1. **VM-Side Token Generation**:
   Generate a fresh scoped token via the Gitea CLI on `core-coord-gitea`:

   ```bash
   NEW_TOKEN=$(ssh -i /srv/admin/secrets/id_ansible ansible@10.10.1.12 \
     "docker exec -u git core-gitea gitea admin user generate-access-token --username utility --token-name 'ci-token-$(date +%s)' --scopes repo,package --raw -c /data/gitea/conf/app.ini")
   ```

2. **Host-Side Storage**:
   Save the new token on the administration host:

   ```bash
   echo -n "${NEW_TOKEN}" | sudo tee /srv/admin/secrets/gitea_utility_token > /dev/null
   sudo chmod 0600 /srv/admin/secrets/gitea_utility_token
   sudo chown ruslan:sudo /srv/admin/secrets/gitea_utility_token
   ```

3. **VM-Side Atlantis Propagation**:
   Apply the new token to Atlantis by updating its container environment:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini site.yml --tags gitea
   ```

4. **Downstream CI / Registry Secrets**:
   Update the `GITEA_REGISTRY_TOKEN` secret in the application repository settings on Gitea (or organization secrets) so GitHub/Gitea Actions pipelines can continue pushing container images.

### Atlantis Webhook Secret

The webhook secret validates that inbound webhooks received by Atlantis originate genuinely from Gitea.

1. **Host-Side Secret Generation**:
   Generate a new random webhook secret on the administration host:

   ```bash
   openssl rand -base64 24 | tr -d '\n' | sudo tee /srv/admin/secrets/atlantis_webhook_secret > /dev/null
   sudo chmod 0600 /srv/admin/secrets/atlantis_webhook_secret
   sudo chown ruslan:sudo /srv/admin/secrets/atlantis_webhook_secret
   ```

2. **VM-Side Atlantis Container Update**:
   Update `ATLANTIS_GITEA_WEBHOOK_SECRET` in the Atlantis container configuration:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini site.yml --tags gitea
   ```

3. **Gitea Webhook Settings**:
   In Gitea repository settings &rarr; **Webhooks** &rarr; select the Atlantis webhook &rarr; update the **Secret** field with the contents of `/srv/admin/secrets/atlantis_webhook_secret`.

### Infisical Administrator Password

1. **Host-Side Password Generation**:
   Archive the current administrator password and generate a replacement secret:

   ```bash
   cp /srv/admin/secrets/infisical_admin_password /srv/admin/secrets/infisical_admin_password.old
   openssl rand -base64 24 | tr -d '\n' | sudo tee /srv/admin/secrets/infisical_admin_password > /dev/null
   sudo chmod 0600 /srv/admin/secrets/infisical_admin_password*
   sudo chown ruslan:sudo /srv/admin/secrets/infisical_admin_password*
   ```

2. **Web Console Password Update**:
   Log in to the Infisical Web UI at `https://infisical.<domain>` with existing credentials. Navigate to **Account Settings** &rarr; **Security** &rarr; **Change Password**, provide the previous password (from `/srv/admin/secrets/infisical_admin_password.old`), and set the new password (from `/srv/admin/secrets/infisical_admin_password`).

3. **Ansible Secrets Synchronization**:
   Update `infisical_admin_password` in `/srv/admin/ansible/group_vars/all/secrets.yml`.

### Infisical User Passwords

1. **Self-Service Rotation**:
   Individual users log in to the Infisical Web UI at `https://infisical.<domain>`, navigate to **Personal Settings** &rarr; **Security** &rarr; **Change Password**, and submit their updated credentials.

2. **Administrative Reset**:
   An administrator can navigate to the **Server Admin Console** &rarr; **Access Control** &rarr; **Users**, select the target user, and trigger a password reset or re-issue an invitation link.

### Infisical CI/CD Machine Identity and Service Token Access Keys

Programmatic secrets access in automation workflows uses Infisical Service Tokens or Universal Auth Machine Identities. To rotate CI/CD access keys without pipeline interruption:

1. **Token Generation**:
   In the Infisical Web UI, navigate to the target project (e.g. `CI/CD`) &rarr; **Project Settings** &rarr; **Service Tokens** (or **Machine Identities**). Create a new token with:
   - Name: `cicd-token-<timestamp>`
   - Environment: `main`
   - Scopes: `Read/Write` (or scoped permissions required by the build runner)
   - Expiration: `Never` (no invalid time)

   Copy the token value (`st.xxxxxxxx...`) immediately upon generation.

2. **Repository Secret Update**:
   In the Git repository (or organization-wide settings in Gitea), navigate to **Settings** &rarr; **Actions** &rarr; **Secrets** and update the `INFISICAL_TOKEN` secret with the newly created access token.

3. **Pipeline Verification**:
   Trigger a test workflow or pipeline job to verify that secrets can be fetched and decrypted properly with the new token.

4. **Revocation**:
   Once verified, return to Infisical &rarr; **Project Settings** &rarr; **Service Tokens**, locate the previous token, and click **Revoke / Delete**.
