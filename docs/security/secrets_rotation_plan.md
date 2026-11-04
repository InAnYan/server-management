# Secrets Rotation Plan

<!-- [impl->req~secrets-rotation-plan-described~1] -->
This document outlines the operational procedures for managing and rotating credentials and administrative accounts across the infrastructure.

## Credential Storage Policy

All persistent administrative credentials reside strictly on the host in `/srv/secrets/` with mode `0700` (`ruslan:sudo`) and individual secret files set to `0600`:

- `/srv/secrets/postgres_admin_password`: Core PostgreSQL superuser password
- `/srv/secrets/dev_postgres_admin_password`: Development PostgreSQL superuser password
- `/srv/secrets/prod_postgres_admin_password`: Production PostgreSQL superuser password
- `/srv/secrets/technitium_admin_password`: Technitium DNS web console admin password
- `/srv/secrets/uptime_kuma_admin_password`: Uptime Kuma administrator password
- `/srv/secrets/uptime_kuma_probe_password`: Unprivileged PostgreSQL monitor probe user password
- `/srv/secrets/technitium_api_token`: Persistent API token for Technitium DNS automation
- `/srv/secrets/gitea_admin_password`: Gitea administrator account password
- `/srv/secrets/gitea_db_password`: Gitea dedicated PostgreSQL database role password

Coordinator and application containers receive credentials via environment variables or API calls at runtime. PostgreSQL instances store `POSTGRES_PASSWORD` in `/opt/postgres/docker-compose.yml` (strictly protected with `0600 root:root` permissions) to satisfy initial database bootstrap.

## Automated Admin Password Rotation (Ingress Isolation)

<!-- [oman->req~secrets-rotation-ansible~1] -->
To rotate admin passwords safely without exposing services to unauthenticated public requests during credential transitions, use the automated rotation playbook:

```bash
cd /srv/admin/ansible
ansible-playbook -i inventory/hosts.ini playbooks/ops/rotate_admin_passwords.yml
```

### Rotation Lifecycle

1. **Ingress Isolation**: Caddy immediately switches public routes (`dns.<domain>`, `status.<domain>`) to maintenance mode, serving HTTP 503 to all public traffic.
2. **PostgreSQL Rotation**: The superuser password is reset directly over local Unix domain socket inside `core-data-postgres` via `ALTER ROLE`.
3. **Technitium Rotation**: Authenticates using the previous session credentials, calls `/api/user/changePassword`, updates the PBKDF2 hash, and generates a fresh automation API token in `/srv/secrets/technitium_api_token`.
4. **Uptime Kuma Rotation**: Connects via internal Socket.IO, authenticates the admin user, and triggers `changePassword`. Note: Existing monitor definitions and status pages are left completely untouched.
5. **Ingress Restoration**: Caddy reloads with normal reverse proxy routing, restoring public access.

## Provisioning Additional Administrator Accounts

To create a new administrator account on Technitium DNS, Uptime Kuma, or both services simultaneously without exposing credentials in compose files:

```bash
cd /srv/admin/ansible

# Provision on both Technitium and Uptime Kuma
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "username=newadmin" \
  -e "password=NewSecretPassword123!"

# Provision only on Technitium DNS (with optional display name)
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=technitium" \
  -e "username=dnsadmin" \
  -e "password=NewSecretPassword123!" \
  -e "display_name='DNS Operator'"

# Provision only on Uptime Kuma
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=uptimekuma" \
  -e "username=kumaadmin" \
  -e "password=NewSecretPassword123!"

# Provision administrator on Gitea
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_admin_user.yml \
  -e "service=gitea" \
  -e "username=gitadmin" \
  -e "email=gitadmin@example.com" \
  -e "password=NewSecretPassword123!"
```

## Provisioning Gitea User Accounts

To provision a regular user account or administrator account directly in Gitea:

```bash
cd /srv/admin/ansible

# Create standard user account (non-admin)
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_gitea_user.yml \
  -e "username=developer" \
  -e "email=developer@example.com" \
  -e "password=DevSecretPassword123!" \
  -e "is_admin=false"

# Create administrator account
ansible-playbook -i inventory/hosts.ini playbooks/ops/create_gitea_user.yml \
  -e "username=teamlead" \
  -e "email=teamlead@example.com" \
  -e "password=LeadSecretPassword123!" \
  -e "is_admin=true"
```

## Manual Service-Specific Procedures

### PostgreSQL Superuser Password

1. Write the new secret to the appropriate secret file (e.g. `postgres_admin_password`, `dev_postgres_admin_password`, or `prod_postgres_admin_password`):

   ```bash
   openssl rand -base64 24 > /srv/secrets/postgres_admin_password
   chmod 600 /srv/secrets/postgres_admin_password
   ```

2. Apply the change via local container socket on the respective database host:

   - **Core (`core-data-postgres`, `10.10.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.10.2.10 \
       "docker exec -i core-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/secrets/postgres_admin_password)';\""
     ```

   - **Dev (`dev-data-postgres`, `10.20.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.20.2.10 \
       "docker exec -i dev-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/secrets/dev_postgres_admin_password)';\""
     ```

   - **Prod (`prod-data-postgres`, `10.30.2.10`)**:

     ```bash
     ssh -i /srv/admin/secrets/id_ansible ansible@10.30.2.10 \
       "docker exec -i prod-postgres psql -U postgres -c \"ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$(cat /srv/secrets/prod_postgres_admin_password)';\""
     ```

3. Update the corresponding group variables if maintaining static overrides: `ansible/group_vars/core_databases.yml`, `ansible/group_vars/dev_databases.yml`, or `ansible/group_vars/prod_databases.yml`.

### Technitium DNS Administrator Password

1. Archive current password and generate new password:

   ```bash
   cp /srv/secrets/technitium_admin_password /srv/secrets/technitium_admin_password.old
   openssl rand -base64 24 > /srv/secrets/technitium_admin_password
   chmod 600 /srv/secrets/technitium_admin_password*
   ```

2. Update `/srv/admin/ansible/group_vars/all/secrets.yml` with `technitium_admin_password` and `technitium_old_admin_password`.
3. Execute the admin setup task:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini site.yml --tags setup_admin
   ```

### Uptime Kuma Administrator Password

1. Archive current password and generate new password:

   ```bash
   cp /srv/secrets/uptime_kuma_admin_password /srv/secrets/uptime_kuma_admin_password.old
   openssl rand -base64 24 > /srv/secrets/uptime_kuma_admin_password
   chmod 600 /srv/secrets/uptime_kuma_admin_password*
   ```

2. Update `/srv/admin/ansible/group_vars/all/secrets.yml` with `uptime_kuma_admin_password` and `uptime_kuma_old_admin_password`.
3. Apply password rotation without touching monitors:

   ```bash
   cd /srv/admin/ansible
   ansible-playbook -i inventory/hosts.ini site.yml --tags setup_admin
   ```
