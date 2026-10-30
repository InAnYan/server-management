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

# 3. Proxmox Resource Pools (docs/networking.md)
resource "proxmox_virtual_environment_pool" "host_managed" {
  pool_id = "host-managed"
  comment = "Core coordinator and baseline services (managed on host)"
}

resource "proxmox_virtual_environment_pool" "git_managed" {
  pool_id = "git-managed"
  comment = "Dev and Prod environments (managed via Git automation)"
}

# 4. Proxmox SDN (Software-Defined Networking)
resource "proxmox_sdn_zone_simple" "local" {
  id   = "local"
  ipam = "pve"
}

# Core Coordinator Network (10.10.1.0/24)
resource "proxmox_sdn_vnet" "vcoord" {
  id    = "vcoord"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-core-coord"
}

resource "proxmox_sdn_subnet" "vcoord_subnet" {
  vnet    = proxmox_sdn_vnet.vcoord.id
  cidr    = "10.10.1.0/24"
  gateway = "10.10.1.1"
  snat    = true
}

# Core Apps Network (10.11.0.0/16)
resource "proxmox_sdn_vnet" "vcore" {
  id    = "vcore"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-core-app"
}

resource "proxmox_sdn_subnet" "vcore_subnet" {
  vnet    = proxmox_sdn_vnet.vcore.id
  cidr    = "10.11.0.0/16"
  gateway = "10.11.0.1"
  snat    = true
}

# Core Databases Network (10.10.2.0/24)
resource "proxmox_sdn_vnet" "vcdb" {
  id    = "vcdb"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-core-data"
}

resource "proxmox_sdn_subnet" "vcdb_subnet" {
  vnet    = proxmox_sdn_vnet.vcdb.id
  cidr    = "10.10.2.0/24"
  gateway = "10.10.2.1"
  snat    = false
}

# Dev Apps Network (10.21.0.0/16)
resource "proxmox_sdn_vnet" "vdev" {
  id    = "vdev"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-dev-app"
}

resource "proxmox_sdn_subnet" "vdev_subnet" {
  vnet    = proxmox_sdn_vnet.vdev.id
  cidr    = "10.21.0.0/16"
  gateway = "10.21.0.1"
  snat    = true
}

# Dev Databases Network (10.20.2.0/24)
resource "proxmox_sdn_vnet" "vddb" {
  id    = "vddb"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-dev-data"
}

resource "proxmox_sdn_subnet" "vddb_subnet" {
  vnet    = proxmox_sdn_vnet.vddb.id
  cidr    = "10.20.2.0/24"
  gateway = "10.20.2.1"
  snat    = false
}

# Prod Apps Network (10.32.0.0/16)
resource "proxmox_sdn_vnet" "vprod" {
  id    = "vprod"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-prod-app"
}

resource "proxmox_sdn_subnet" "vprod_subnet" {
  vnet    = proxmox_sdn_vnet.vprod.id
  cidr    = "10.32.0.0/16"
  gateway = "10.32.0.1"
  snat    = true
}

# Prod Databases Network (10.30.2.0/24)
resource "proxmox_sdn_vnet" "vpdb" {
  id    = "vpdb"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-prod-data"
}

resource "proxmox_sdn_subnet" "vpdb_subnet" {
  vnet    = proxmox_sdn_vnet.vpdb.id
  cidr    = "10.30.2.0/24"
  gateway = "10.30.2.1"
  snat    = false
}

# 5. Apply SDN Configuration to Cluster
resource "proxmox_sdn_applier" "sdn_apply" {
  depends_on = [
    proxmox_sdn_subnet.vcoord_subnet,
    proxmox_sdn_subnet.vcore_subnet,
    proxmox_sdn_subnet.vcdb_subnet,
    proxmox_sdn_subnet.vdev_subnet,
    proxmox_sdn_subnet.vddb_subnet,
    proxmox_sdn_subnet.vprod_subnet,
    proxmox_sdn_subnet.vpdb_subnet
  ]
}
