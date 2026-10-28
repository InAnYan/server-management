terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

# 1. Proxmox Node Firewall Rules
# Must be defined first so that access rules exist before enabling the firewall
resource "proxmox_virtual_environment_firewall_rules" "node_rules" {
  node_name = var.proxmox_node

  # Allow Tailscale WireGuard daemon port from anywhere
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "41641"
    comment = "Allow Tailscale daemon UDP communication"
    enabled = true
  }

  # Allow SSH on port 22 for Tailscale users
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "22"
    iface   = "tailscale0"
    source  = "100.64.0.0/10"
    comment = "Allow SSH from Tailscale network"
    enabled = true
  }

  # Allow Proxmox Web GUI on port 8006 for Tailscale users
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "8006"
    iface   = "tailscale0"
    source  = "100.64.0.0/10"
    comment = "Allow Proxmox Web Dashboard from Tailscale network"
    enabled = true
  }
}

# 2. Datacenter / Cluster Firewall Configuration
# Depends on node rules to ensure rules exist before input policy drops traffic
resource "proxmox_virtual_environment_cluster_firewall" "cluster_firewall" {
  enabled       = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"

  depends_on = [
    proxmox_virtual_environment_firewall_rules.node_rules
  ]
}

# Outputs for server setup configuration
