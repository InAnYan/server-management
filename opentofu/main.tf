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
  enabled        = true
  input_policy   = "DROP"
  output_policy  = "ACCEPT"
  forward_policy = "DROP"

  depends_on = [
    proxmox_virtual_environment_firewall_rules.node_rules
  ]
}

resource "proxmox_node_firewall" "node_firewall" {
  node_name = var.proxmox_node
  enabled   = true
  nftables  = true
}

# [impl->req~cross-environment-isolation~1]
# [impl->req~databases-isolated-from-internet~1]
resource "proxmox_virtual_environment_firewall_rules" "cluster_rules" {
  # --- Explicit ALLOW rules ---

  # 1. Core coordinator to all subnets
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vcore-all"
    comment = "Allow coordinator to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vcdb-all"
    comment = "Allow coordinator to core data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vdev-all"
    comment = "Allow coordinator to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vddb-all"
    comment = "Allow coordinator to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vprod-all"
    comment = "Allow coordinator to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vpdb-all"
    comment = "Allow coordinator to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    comment = "Allow coordinator internet egress"
    enabled = true
  }

  # 2. Core applications
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcore-all"
    dest    = "+sdn/vcdb-all"
    comment = "Allow core app to core data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcore-all"
    comment = "Allow core app internet egress (e.g. DNS resolution)"
    enabled = true
  }

  # 3. Development environment
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vddb-all"
    comment = "Allow dev app to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vdev-all"
    comment = "Allow dev app internet egress"
    enabled = true
  }

  # 4. Production environment
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vpdb-all"
    comment = "Allow prod app to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vprod-all"
    comment = "Allow prod app internet egress"
    enabled = true
  }

  # --- Explicit DROP rules ---

  # Dev isolation
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vprod-all"
    comment = "Drop dev app to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vpdb-all"
    comment = "Drop dev app to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vcore-all"
    comment = "Drop dev app to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vcdb-all"
    comment = "Drop dev app to core data"
    enabled = true
  }

  # Prod isolation
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vdev-all"
    comment = "Drop prod app to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vddb-all"
    comment = "Drop prod app to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vcore-all"
    comment = "Drop prod app to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vcdb-all"
    comment = "Drop prod app to core data"
    enabled = true
  }

  # Database subnets isolation: no cross-environment data access, no WAN egress
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    dest    = "+sdn/vpdb-all"
    comment = "Drop dev data to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    dest    = "+sdn/vprod-all"
    comment = "Drop dev data to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    comment = "Drop dev data internet egress"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    dest    = "+sdn/vddb-all"
    comment = "Drop prod data to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    dest    = "+sdn/vdev-all"
    comment = "Drop prod data to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    comment = "Drop prod data internet egress"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vcdb-all"
    comment = "Drop core data internet egress"
    enabled = true
  }
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
