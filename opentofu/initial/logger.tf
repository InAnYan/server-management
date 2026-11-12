module "logger" {
  source = "../modules/vm"

  name         = "core-coord-logger"
  description  = "Loki centralized log aggregator and Grafana dashboard"
  node_name    = var.node_name
  vm_id        = 1400
  pool_id      = var.pools.core_coord
  cores        = 2
  memory       = 1536
  disk_size    = 25
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.14/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "3100"
      comment = "Allow Loki log ingestion from VMs"
    },
    {
      dport   = "3000"
      comment = "Allow Grafana Web UI from Caddy reverse proxy"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "logger_backup" {
  id       = "backup-core-coord-logger"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.logger.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
