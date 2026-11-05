# [impl->req~provisioning-opentofu~1]
module "redis_core" {
  source = "../modules/vm"
  count  = var.enable_redis_core ? 1 : 0

  name         = "core-data-redis"
  description  = "Core Valkey / Redis in-memory cache and key-value store"
  node_name    = var.node_name
  vm_id        = 1910
  pool_id      = var.pools.core_data
  cores        = 2
  memory       = 1024
  disk_size    = 15
  image_id     = var.image_id
  vnet_id      = var.vnets.vcdb
  ipv4_address = "10.10.2.11/24"
  ipv4_gateway = "10.10.2.1"

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
resource "proxmox_backup_job" "redis_core_backup" {
  count    = var.enable_redis_core ? 1 : 0
  id       = "backup-core-data-redis"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.redis_core[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
