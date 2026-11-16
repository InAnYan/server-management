# --- SDN Simple Zone ---
# [impl->req~environments-core-dev-prod~1]

resource "proxmox_sdn_zone_simple" "local" {
  id   = "local"
  ipam = "pve"
}

# --- Coordinator Network (vcoord: 10.10.1.0/24) ---

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

# --- Core Applications Network (vcore: 10.11.0.0/16) ---

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

# --- Core Databases Network (vcdb: 10.10.2.0/24) ---

resource "proxmox_sdn_vnet" "vcdb" {
  id    = "vcdb"
  zone  = proxmox_sdn_zone_simple.local.id
  alias = "vnet-core-data"
}

# [impl->req~databases-isolated-from-internet~1]
resource "proxmox_sdn_subnet" "vcdb_subnet" {
  vnet    = proxmox_sdn_vnet.vcdb.id
  cidr    = "10.10.2.0/24"
  gateway = "10.10.2.1"
  snat    = false
}

# --- Development Applications Network (vdev: 10.21.0.0/16) ---
# [impl->req~cross-environment-isolation~1]

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

# --- Development Databases Network (vddb: 10.20.2.0/24) ---

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

# --- Production Applications Network (vprod: 10.32.0.0/16) ---

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

# --- Production Databases Network (vpdb: 10.30.2.0/24) ---

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

# --- SDN Applier ---

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
