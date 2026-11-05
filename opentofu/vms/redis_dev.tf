# [impl->req~provisioning-opentofu~1]
module "redis_dev" {
  source = "../modules/vm"
  count  = var.enable_redis_dev ? 1 : 0

  name         = "dev-data-redis"
  description  = "Development Valkey / Redis in-memory cache and key-value store"
  node_name    = var.node_name
  vm_id        = 2910
  pool_id      = var.pools.dev_data
  cores        = 2
  memory       = 1024
  disk_size    = 15
  image_id     = var.image_id
  vnet_id      = var.vnets.vddb
  ipv4_address = "10.20.2.11/24"
  ipv4_gateway = "10.20.2.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "6379"
      comment = "Allow Redis / Valkey client connections"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

# [impl->req~backups-opentofu~1]
resource "proxmox_backup_job" "redis_dev_backup" {
  count    = var.enable_redis_dev ? 1 : 0
  id       = "backup-dev-data-redis"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.redis_dev[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
