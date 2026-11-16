"""Pytest configuration and environment fixtures for integration test suite.

All configuration parameters and secrets are read strictly from environment variables.
"""

import os
import pytest


@pytest.fixture
def host_tailscale_ip():
    """Proxmox host Tailscale IPv4 address."""
    return os.getenv("SERVER_TAILSCALE_IP", "")


@pytest.fixture
def host_public_ip():
    """Proxmox host WAN public IPv4 address."""
    return os.getenv("SERVER_PUBLIC_IP", "")


@pytest.fixture
def domain():
    """Primary platform domain."""
    return os.getenv("BASE_DOMAIN", "example.com")


@pytest.fixture
def ssh_user():
    """Host SSH administration username."""
    return os.getenv("SSH_USER", "admin")


@pytest.fixture
def ssh_port():
    """Host hardened SSH listening port."""
    return os.getenv("SSH_PORT", "2222")


@pytest.fixture
def ssh_key():
    """Path to host administrator SSH private key."""
    return os.getenv("SSH_KEY", "")


@pytest.fixture
def vm_ssh_key():
    """Path to VM automation SSH private key."""
    return os.getenv("VM_SSH_KEY", "")
