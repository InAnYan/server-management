# --- Pool Backup Jobs ---
# [impl->req~backups-opentofu~1]

resource "proxmox_backup_job" "core_data_backup" {
  id       = "backup-core-data"
  node     = var.proxmox_node
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  pool     = proxmox_virtual_environment_pool.core_data.pool_id

  prune_backups = {
    "keep-last" = "3"
  }
}

resource "proxmox_backup_job" "dev_data_backup" {
  id       = "backup-dev-data"
  node     = var.proxmox_node
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  pool     = proxmox_virtual_environment_pool.dev_data.pool_id

  prune_backups = {
    "keep-last" = "3"
  }
}

resource "proxmox_backup_job" "prod_data_backup" {
  id       = "backup-prod-data"
  node     = var.proxmox_node
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  pool     = proxmox_virtual_environment_pool.prod_data.pool_id

  prune_backups = {
    "keep-last" = "3"
  }
}
