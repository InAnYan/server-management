# [impl->req~provisioning-opentofu~1]
module "redis_prod" {
  source = "../modules/vm"
  count  = var.enable_redis_prod ? 1 : 0

  name         = "prod-data-redis"
  description  = "Production Valkey / Redis in-memory cache and key-value store"
  node_name    = var.node_name
  vm_id        = 3910
  pool_id      = var.pools.prod_data
  cores        = 2
  memory       = 1024
  disk_size    = 15
  image_id     = var.image_id
  vnet_id      = var.vnets.vpdb
  ipv4_address = "10.30.2.11/24"
  ipv4_gateway = "10.30.2.1"

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
resource "proxmox_backup_job" "redis_prod_backup" {
  count    = var.enable_redis_prod ? 1 : 0
  id       = "backup-prod-data-redis"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.redis_prod[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
