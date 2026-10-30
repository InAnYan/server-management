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
}

resource "proxmox_virtual_environment_cluster_firewall" "cluster_firewall" {
  enabled       = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"

  depends_on = [
    proxmox_virtual_environment_firewall_rules.node_rules
  ]
}

resource "proxmox_virtual_environment_pool" "host_managed" {
  pool_id = "host-managed"
  comment = "Core coordinator and baseline services (managed on host)"
}

resource "proxmox_virtual_environment_pool" "git_managed" {
  pool_id = "git-managed"
  comment = "Dev and Prod environments (managed via Git automation)"
}

resource "proxmox_sdn_zone_simple" "local" {
  id   = "local"
  ipam = "pve"
}

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
