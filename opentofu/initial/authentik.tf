module "authentik" {
  source = "../modules/vm"

  name         = "core-coord-authentik"
  description  = "Authentik centralized identity provider and SSO authentication server"
  node_name    = var.node_name
  vm_id        = 1450
  cores        = 2
  memory       = 2048
  disk_size    = 20
  pool_id      = var.pools.core_coord
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.15/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "9000"
      comment = "Allow Authentik Web UI and API"
    },
    {
      dport   = "9443"
      comment = "Allow Authentik HTTPS Outpost"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "authentik_backup" {
  id       = "backup-core-coord-authentik"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.authentik.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
