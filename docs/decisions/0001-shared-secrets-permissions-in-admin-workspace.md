# Shared Secrets Permissions in `/srv/admin` Workspace

- Status: accepted
- Date: 2026-10-28

## Context and Problem Statement

The repository runs in the common directory `/srv/admin` on the Proxmox host, shared between all authorized system administrators. Infrastructure secrets (such as `.env`, `terraform/*/terraform.tfvars`, and Ansible `secrets.yml`) are kept unencrypted in plaintext locally and strictly excluded from Git.

Initially, secret files were restricted to `chmod 600` (`rw-------`). Under `600` permissions, only the single operator who originally created or uploaded the file can read it. Other system administrators belonging to the `sudo` group are unable to read the secrets, causing OpenTofu and Ansible operations to fail unless users explicitly switch to root (`sudo -i`).

How should secret file permissions be structured in `/srv/admin` to enable seamless multi-administrator operations while preserving isolation from unprivileged users?

## Decision Drivers

- **Collaboration**: Multiple operators in the `sudo` group must be able to run OpenTofu plans/applies and Ansible playbooks under their individual user accounts.
- **Principle of Least Privilege**: Non-admin system users and daemon processes must have zero access to infrastructure secrets.
- **Operational Simplicity**: Avoid requiring administrators to constantly run IaC tools as `root`.

## Considered Options

- **Option 1: Group-readable secrets (`chmod 660`, group `sudo`)** with directory setgid (`chmod 2770`).
- **Option 2: Strict user-only permissions (`chmod 600`)** requiring administrators to switch to `root` (`sudo -i`) for every IaC command.
- **Option 3: POSIX Access Control Lists (ACLs)** using `setfacl` to grant explicit read/write access to group `sudo`.

## Decision Outcome

Chosen option: **Option 1 ("Group-readable secrets with `chmod 660` and `root:sudo` ownership")**, because it natively aligns with the directory's setgid model and requires no external ACL tooling.

### Detailed Configuration

1. **Workspace Directory**: `/srv/admin` is configured with `chmod 2770` (`rwxrws---`) and owned by `root:sudo`. The `setgid` bit (`2`) ensures all files and subdirectories created within `/srv/admin` automatically inherit the `sudo` group.
2. **Secret Files**: All uncommitted secret files (`.env`, `terraform/*/terraform.tfvars`, `ansible/**/secrets.yml`) have permissions set to `chmod 660` (`rw-rw----`) and group set to `sudo`.
3. **Outsider Access**: The `other` permission bits remain strictly `0` (`---`), preventing any non-sudo user from traversing the directory or reading secrets.

### Positive Consequences

- All administrators in the `sudo` group can run OpenTofu and Ansible directly using their personal shell sessions.
- Files created by administrators in `/srv/admin` inherit the `sudo` group automatically via setgid.
- Non-admin users, web daemons, and guest processes cannot read or traverse `/srv/admin`.

### Negative Consequences

- Any compromised user account within the `sudo` group exposes all local infrastructure secrets (accepted risk, as members of the `sudo` group already possess full administrative privileges).

## Pros and Cons of the Options

### Option 1: Group-readable secrets (`chmod 660`, group `sudo`)

- Good, because standard UNIX permissions work across all tools and scripts without extra packages.
- Good, because administrators can collaborate transparently without escalating to root.
- Bad, because manual file transfers (`scp`) must ensure group permissions (`chmod 660`) are applied after copying.

### Option 2: Strict user-only permissions (`chmod 600`)

- Good, because only the file creator has direct read access.
- Bad, because other administrators must `sudo su` or `sudo tofu` to run infrastructure commands.
- Bad, because running IaC tools as root pollutes file ownership and caches in the repository.

### Option 3: POSIX Access Control Lists (ACLs)

- Good, because default ACLs can automatically enforce permissions on newly copied files.
- Bad, because ACLs introduce complexity, are filesystem-dependent, and are not visible in standard `ls -l` without `getfacl`.
