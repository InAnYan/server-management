terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}

# [impl->req~provisioning-opentofu~1]
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

# --- Host Firewall Rules ---

resource "proxmox_virtual_environment_firewall_rules" "node_rules" {
  node_name = var.proxmox_node

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "41641"
    comment = "Allow Tailscale daemon UDP communication"
    enabled = true
  }

  # [impl->req~host-access-tailscale-only~1]
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

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80"
    comment = "Allow HTTP for Caddy reverse proxy"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "443"
    comment = "Allow HTTPS for Caddy reverse proxy"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "53"
    comment = "Allow DNS UDP queries on host"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "53"
    comment = "Allow DNS TCP queries on host"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "2222"
    comment = "Allow Git SSH for Gitea service"
    enabled = true
  }
}

# [impl->req~firewall-enabled~1]
resource "proxmox_virtual_environment_cluster_firewall" "cluster_firewall" {
  enabled       = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"

  depends_on = [
    proxmox_virtual_environment_firewall_rules.node_rules
  ]
}

# --- Resource Pools ---

resource "proxmox_virtual_environment_pool" "core_coord" {
  pool_id = "core-coord"
  comment = "Core coordinator workloads (Caddy, Uptime Kuma)"
}

resource "proxmox_virtual_environment_pool" "core_app" {
  pool_id = "core-app"
  comment = "Core application workloads (Technitium)"
}

resource "proxmox_virtual_environment_pool" "core_data" {
  pool_id = "core-data"
  comment = "Core data and database persistence workloads"
}

resource "proxmox_virtual_environment_pool" "dev_app" {
  pool_id = "dev-app"
  comment = "Development application workloads"
}

resource "proxmox_virtual_environment_pool" "dev_data" {
  pool_id = "dev-data"
  comment = "Development data and database persistence workloads"
}

resource "proxmox_virtual_environment_pool" "prod_app" {
  pool_id = "prod-app"
  comment = "Production application workloads"
}

resource "proxmox_virtual_environment_pool" "prod_data" {
  pool_id = "prod-data"
  comment = "Production data and database persistence workloads"
}
