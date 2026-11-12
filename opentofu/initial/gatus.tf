# [impl->req~service-uptime-monitoring~1]
module "gatus" {
  source = "../modules/vm"

  name         = "core-coord-gatus"
  description  = "Gatus automated service health dashboard and status page"
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
      dport   = "80"
      comment = "Allow Gatus Production Web UI (status)"
    },
    {
      dport   = "8081"
      comment = "Allow Gatus Development Web UI (status-dev)"
    },
    {
      dport   = "8082"
      comment = "Allow Gatus Internal Web UI (status-internal)"
    },
    {
      dport   = "8080"
      comment = "Allow Gatus internal HTTP port"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "gatus_backup" {
  id       = "backup-core-coord-gatus"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.gatus.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
