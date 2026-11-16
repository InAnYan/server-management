# Platform Security Integration Test Suite

This directory contains integration tests (`itest`) that validate security boundaries, firewall isolation, authentication constraints, and privilege separation against a live server deployment.

Unlike unit tests, these integration tests verify live infrastructure behavior over the network and SSH.

## Prerequisites

- Python 3.10+
- `pytest` (e.g. `pip install pytest`)
- Connectivity to the server host (via Tailscale or management network)
- Operator SSH keys (e.g. `secrets/id_admin`, `secrets/id_ansible`)

## Running the Tests

To protect sensitive operational data, all parameters and secrets are passed strictly via environment variables (refer to local `PRIVATE.md` for actual server values):

```bash
SERVER_TAILSCALE_IP="<tailscale-ip>" \
SERVER_PUBLIC_IP="<public-ip>" \
BASE_DOMAIN="<your-domain>" \
SSH_USER="admin" \
SSH_PORT="2222" \
SSH_KEY="~/.ssh/id_admin" \
VM_SSH_KEY="secrets/id_ansible" \
pytest tests/ -v
```

### Configuration Environment Variables

| Environment Variable | Description | Default |
| :--- | :--- | :--- |
| `SERVER_TAILSCALE_IP` | Host Tailscale IPv4 address | `""` (required) |
| `SERVER_PUBLIC_IP` | Host public WAN IPv4 address | `""` (required) |
| `BASE_DOMAIN` | Primary platform domain | `example.com` |
| `SSH_USER` | Host administrator SSH user | `admin` |
| `SSH_PORT` | Host hardened SSH port | `2222` |
| `SSH_KEY` | Path to host administrator SSH private key | `""` |
| `VM_SSH_KEY` | Path to VM automation SSH private key | `""` |

## Covered Security Requirements (Traceability)

Each test satisfies an integration test requirement (`itest`) defined in [docs/requirements.md](../docs/requirements.md):

| Test Function | OpenFastTrace Requirement | Security Property Verified |
| :--- | :--- | :--- |
| `test_git_service_private_authentication_required` | `req~git-service-private-authentication-required~1` | Unauthenticated HTTP requests to Gitea are denied (returns 401/403 or redirects to login) |
| `test_logging_ui_private_authentication_required` | `req~logging-ui-private-authentication-required~1` | Grafana API requires authentication; public user signup is disabled |
| `test_host_access_tailscale_only` | `req~host-access-tailscale-only~1` | Port 8006 (Proxmox GUI) is blocked on public WAN and accessible strictly via Tailscale |
| `test_host_ssh_port_2222_key_only` | `req~host-ssh-port-2222-key-only~1` | Host SSH listens on port 2222; password authentication attempts are rejected |
| `test_host_access_ssh_keys_only` | `req~host-access-ssh-keys-only~1` | Host SSH enforces key-only authentication; password authentication is disabled |
| `test_vm_access_ssh_keys_only` | `req~vm-access-ssh-keys-only~1` | Virtual machine SSH daemons reject password authentication across all nodes |
| `test_databases_isolated_from_internet` | `req~databases-isolated-from-internet~1` | Database subnets have no internet egress routing; outbound WAN traffic fails |
| `test_cross_environment_isolation` | `req~cross-environment-isolation~1` | Development tier VMs cannot communicate with production tier VMs across SDN VNets |
| `test_qemu_agent_capabilities_restricted` | `req~qemu-agent-capabilities-restricted~1` | `guest-exec` RPC is disabled; observability RPCs (`ping`, `interfaces`) succeed |
| `test_proxmox_api_keys_pve_realm` | `req~proxmox-api-keys-pve-realm~1` | Automation users reside in the `@pve` realm and never in `@pam` |
| `test_gitops_api_permissions_minimal` | `req~gitops-api-permissions-minimal~1` | Atlantis automation tokens do not hold `Administrator` on `/` and are scoped to pools |
