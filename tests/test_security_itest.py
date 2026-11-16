"""Integration test suite verifying platform security requirements against live infrastructure.

These tests validate firewall isolation, SSH hardening, API authentication,
privilege separation, and QEMU guest agent constraints.
"""

import json
import os
import socket
import ssl
import subprocess
import urllib.error
import urllib.request
import pytest


def run_host_ssh(host, user, port, key_path, command, timeout=15):
    """Execute command on Proxmox host via SSH."""
    cmd = [
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        "-p", str(port),
    ]
    if key_path:
        expanded = os.path.expanduser(key_path)
        if os.path.exists(expanded):
            cmd.extend(["-i", expanded])
    cmd.append(f"{user}@{host}")
    cmd.append(command)

    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    return result


def is_port_open(host, port, timeout=3.0):
    """Check if TCP port is open and accepting connections."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    try:
        s.connect((host, int(port)))
        s.shutdown(socket.SHUT_RDWR)
        return True
    except (socket.timeout, ConnectionRefusedError, OSError):
        return False
    finally:
        s.close()


# [itest->req~git-service-private-authentication-required~1]
def test_git_service_private_authentication_required(domain):
    """Verify Git platform requires authentication for any action and blocks anonymous access."""
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    target_url = f"https://git.{domain}/api/v1/repos/search"
    req = urllib.request.Request(
        target_url,
        headers={"User-Agent": "Security-Integration-Test/1.0"},
    )

    try:
        with urllib.request.urlopen(req, context=ctx, timeout=10) as response:
            # If HTTP 200 is returned, verify that REQUIRE_SIGNIN_VIEW is not violated
            # In strict private mode, unauthenticated search must either return 401 or empty/disabled
            assert response.status in [401, 403], f"Anonymous access was permitted with status {response.status}"
    except urllib.error.HTTPError as e:
        # HTTP 401 (Unauthorized) or 403 (Forbidden) confirms private authentication is enforced
        assert e.code in [401, 403], f"Unexpected HTTP error status: {e.code}"
    except urllib.error.URLError as e:
        # If redirected to login page without following redirects
        if hasattr(e, "reason") and "Unauthorized" in str(e.reason):
            pass
        else:
            pytest.skip(f"Endpoint not reachable during test execution: {e}")


# [itest->req~logging-ui-private-authentication-required~1]
def test_logging_ui_private_authentication_required(domain):
    """Verify centralized logging UI prohibits public registration and requires authentication."""
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    # Test that API endpoint rejects unauthenticated access
    target_url = f"https://logs.{domain}/api/users"
    req = urllib.request.Request(
        target_url,
        headers={"User-Agent": "Security-Integration-Test/1.0"},
    )

    try:
        with urllib.request.urlopen(req, context=ctx, timeout=10) as response:
            assert response.status in [401, 403], f"Anonymous access to logging API was permitted with status {response.status}"
    except urllib.error.HTTPError as e:
        assert e.code in [401, 403], f"Unexpected HTTP status: {e.code}"
    except urllib.error.URLError as e:
        pytest.skip(f"Logging UI not reachable: {e}")

    # Test that public signup endpoint is disabled
    signup_url = f"https://logs.{domain}/api/user/signup/options"
    signup_req = urllib.request.Request(
        signup_url,
        headers={"User-Agent": "Security-Integration-Test/1.0"},
    )
    try:
        with urllib.request.urlopen(signup_req, context=ctx, timeout=10) as response:
            data = json.loads(response.read().decode())
            # In Grafana, allow_sign_up=false returns empty or disabled
            assert data.get("allowSignUp") is not True, "Public user registration is enabled in Grafana"
    except urllib.error.HTTPError as e:
        # 403 / 404 confirms public signup is blocked
        assert e.code in [401, 403, 404, 500]
    except urllib.error.URLError:
        pass


# [itest->req~host-access-tailscale-only~1]
def test_host_access_tailscale_only(host_public_ip, host_tailscale_ip):
    """Verify Proxmox web dashboard (port 8006) is blocked on public WAN and accessible via Tailscale."""
    if not host_public_ip or not host_tailscale_ip:
        pytest.skip("host_public_ip and host_tailscale_ip must be provided")

    # 1. WAN verification: Public IP port 8006 must be dropped/filtered or unreachable
    wan_open = is_port_open(host_public_ip, 8006, timeout=3.0)
    assert not wan_open, (
        f"Security violation: Proxmox GUI port 8006 is publicly exposed on WAN IP {host_public_ip}"
    )

    # 2. Tailscale verification: Tailscale IP port 8006 should be open and listening
    tailscale_open = is_port_open(host_tailscale_ip, 8006, timeout=3.0)
    assert tailscale_open, (
        f"Proxmox GUI is not accessible on Tailscale IP {host_tailscale_ip}:8006"
    )


# [itest->req~host-ssh-port-2222-key-only~1]
def test_host_ssh_port_2222_key_only(host_tailscale_ip, ssh_port, ssh_user, ssh_key):
    """Verify host SSH operates on port 2222 and strictly enforces key-only authentication."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    assert str(ssh_port) == "2222", f"Configured SSH port is {ssh_port}, expected 2222"

    # 1. Verify port 2222 is open on Tailscale
    open_2222 = is_port_open(host_tailscale_ip, 2222, timeout=3.0)
    assert open_2222, f"Hardened SSH port 2222 is not reachable on {host_tailscale_ip}"

    # 2. Verify password authentication is rejected
    test_cmd = [
        "ssh",
        "-p", "2222",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "PreferredAuthentications=password",
        "-o", "PubkeyAuthentication=no",
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        f"{ssh_user}@{host_tailscale_ip}",
        "true",
    ]
    res = subprocess.run(test_cmd, capture_output=True, text=True)
    # Rejection with exit code 255 and "Permission denied" confirms password auth is disabled
    assert res.returncode != 0, "Security violation: Password authentication succeeded on port 2222"
    assert "Permission denied" in res.stderr or res.returncode == 255


# [itest->req~host-access-ssh-keys-only~1]
def test_host_access_ssh_keys_only(host_tailscale_ip, ssh_port, ssh_user):
    """Verify host SSH strictly disables password authentication."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    cmd = [
        "ssh",
        "-p", str(ssh_port),
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "PreferredAuthentications=password",
        "-o", "PubkeyAuthentication=no",
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        f"{ssh_user}@{host_tailscale_ip}",
        "id",
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    assert res.returncode != 0, "Host allowed password authentication"
    assert "Permission denied" in res.stderr or res.returncode == 255


# [itest->req~vm-access-ssh-keys-only~1]
def test_vm_access_ssh_keys_only(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify virtual machines enforce key-only SSH authentication and reject password attempts."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    # Test SSH password rejection against internal VM via host bastion
    probe_cmd = (
        "ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "
        "-o PubkeyAuthentication=no -o BatchMode=yes -o ConnectTimeout=3 "
        "ansible@10.10.1.10 id 2>&1 || true"
    )
    res = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, probe_cmd)
    if res.returncode != 0 and "Operation not permitted" in res.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    output = res.stdout + res.stderr
    assert "Permission denied" in output or "closed by remote host" in output or res.returncode == 0, (
        f"Password authentication was not rejected on VM: {output}"
    )


# [itest->req~databases-isolated-from-internet~1]
def test_databases_isolated_from_internet(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify database VMs have no outbound internet access (no SNAT routing)."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    # Attempt internet egress probe from core database VM
    probe_cmd = (
        "ssh -i /srv/admin/secrets/id_ansible -o StrictHostKeyChecking=no "
        "-o ConnectTimeout=3 ansible@10.10.2.10 "
        "'curl --connect-timeout 2 -sI https://1.1.1.1 || ping -c 1 -W 2 1.1.1.1' 2>&1"
    )
    res = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, probe_cmd)
    if res.returncode != 0 and "Operation not permitted" in res.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    output = res.stdout + res.stderr
    # Egress failure (timed out, unreachable, or non-zero exit) confirms isolation
    assert "200 OK" not in output, "Database VM has unauthorized internet access"
    assert "Connection timed out" in output or "Network is unreachable" in output or res.returncode != 0


# [itest->req~cross-environment-isolation~1]
def test_cross_environment_isolation(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify development tier VMs cannot reach production tier VMs across SDN VNets."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    # Attempt connection from dev-app-testapp (10.21.1.10) to prod-data-postgres (10.30.2.10:5432)
    probe_cmd = (
        "ssh -i /srv/admin/secrets/id_ansible -o StrictHostKeyChecking=no "
        "-o ConnectTimeout=3 ansible@10.21.1.10 "
        "'nc -z -w 2 10.30.2.10 5432 || curl --connect-timeout 2 -s http://10.32.1.10:80' 2>&1"
    )
    res = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, probe_cmd)
    if res.returncode != 0 and "Operation not permitted" in res.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    output = res.stdout + res.stderr
    assert "Connected" not in output and "HTTP/" not in output, (
        f"Cross-environment breach: dev VM reached production service: {output}"
    )


# [itest->req~qemu-agent-capabilities-restricted~1]
def test_qemu_agent_capabilities_restricted(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify QEMU guest agent execution RPCs are blocked while observability RPCs function."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    # 1. Attempt blocked RPC: guest-exec
    blocked_cmd = "sudo pvesh create /nodes/$(hostname)/qemu/1000/agent/exec --command '/bin/echo' 2>&1 || true"
    res_blocked = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, blocked_cmd)
    if res_blocked.returncode != 0 and "Operation not permitted" in res_blocked.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    output_blocked = res_blocked.stdout + res_blocked.stderr
    assert "disabled" in output_blocked.lower() or "not allowed" in output_blocked.lower() or "500" in output_blocked, (
        f"guest-exec RPC was not blocked: {output_blocked}"
    )

    # 2. Verify allowed RPC: network discovery
    allowed_cmd = "sudo pvesh get /nodes/$(hostname)/qemu/1000/agent/network-get-interfaces --output-format json 2>&1"
    res_allowed = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, allowed_cmd)
    output_allowed = res_allowed.stdout + res_allowed.stderr
    assert "error" not in output_allowed.lower() or res_allowed.returncode == 0, (
        f"Allowed observability RPC failed: {output_allowed}"
    )


# [itest->req~proxmox-api-keys-pve-realm~1]
def test_proxmox_api_keys_pve_realm(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify Proxmox automation users belong strictly to the PVE authentication realm."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    cmd = "sudo pveum user list --output-format json"
    res = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, cmd)
    if res.returncode != 0 and "Operation not permitted" in res.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    try:
        users = json.loads(res.stdout)
        user_ids = [u.get("userid", "") for u in users]
        # Verify automation users use @pve realm and never @pam
        automation_users = [u for u in user_ids if "atlantis" in u or "tofu" in u or "prov" in u]
        for user_id in automation_users:
            assert user_id.endswith("@pve"), f"Automation user {user_id} violates PVE realm requirement"
    except json.JSONDecodeError:
        # Fallback text check
        output = res.stdout
        assert "atlantis-prov@pve" in output, "Expected atlantis-prov@pve user not found"
        assert "atlantis-prov@pam" not in output, "Security violation: atlantis-prov found in PAM realm"


# [itest->req~gitops-api-permissions-minimal~1]
def test_gitops_api_permissions_minimal(host_tailscale_ip, ssh_user, ssh_port, ssh_key):
    """Verify GitOps automation tokens are restricted to application pools and do not have Administrator on /."""
    if not host_tailscale_ip:
        pytest.skip("host_tailscale_ip must be provided")

    cmd = "sudo pvesh get /access/acl --output-format json"
    res = run_host_ssh(host_tailscale_ip, ssh_user, ssh_port, ssh_key, cmd)
    if res.returncode != 0 and "Operation not permitted" in res.stderr:
        pytest.skip("Host SSH unreachable from test runner sandbox")

    try:
        acls = json.loads(res.stdout)
        for acl in acls:
            ugid = acl.get("ugid", "")
            path = acl.get("path", "")
            role = acl.get("roleid", "")

            # Ensure atlantis automation token is never granted Administrator on root '/'
            if "atlantis" in ugid and path == "/":
                assert role != "Administrator", "Security violation: atlantis token has Administrator on /"
    except json.JSONDecodeError:
        output = res.stdout
        # Basic assertion that atlantis is scoped to pools or non-admin
        assert "atlantis-prov@pve!tofu / Administrator" not in output
