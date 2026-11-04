module "uptimekuma" {
  source = "../modules/vm"

  name         = "core-coord-uptimekuma"
  description  = "Uptime Kuma monitoring service and status dashboard"
  node_name    = var.node_name
  vm_id        = 1100
  pool_id      = var.pools.core_coord
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.11/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "3001"
      comment = "Allow Uptime Kuma Web UI and Socket.IO"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "uptimekuma_backup" {
  id       = "backup-core-coord-uptimekuma"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.uptimekuma.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
