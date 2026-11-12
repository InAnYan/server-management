# [impl->req~provisioning-opentofu~1]
# [impl->req~object-storage-service~1]
module "minio_core" {
  source = "../modules/vm"
  count  = var.enable_minio_core ? 1 : 0

  name         = "core-data-minio"
  description  = "Core MinIO S3-compatible object storage server"
  node_name    = var.node_name
  vm_id        = 1920
  pool_id      = var.pools.core_data
  cores        = 2
  memory       = 2048
  disk_size    = 30
  image_id     = var.image_id
  vnet_id      = var.vnets.vcdb
  ipv4_address = "10.10.2.12/24"
  ipv4_gateway = "10.10.2.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "9000"
      comment = "Allow MinIO S3 API traffic"
    },
    {
      dport   = "9001"
      comment = "Allow MinIO Console Web UI"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

# [impl->req~backups-opentofu~1]
resource "proxmox_backup_job" "minio_core_backup" {
  count    = var.enable_minio_core ? 1 : 0
  id       = "backup-core-data-minio"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.minio_core[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
