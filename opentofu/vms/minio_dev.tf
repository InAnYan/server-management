# [impl->req~provisioning-opentofu~1]
module "minio_dev" {
  source = "../modules/vm"
  count  = var.enable_minio_dev ? 1 : 0

  name         = "dev-data-minio"
  description  = "Development MinIO S3-compatible object storage server"
  node_name    = var.node_name
  vm_id        = 2920
  pool_id      = var.pools.dev_data
  cores        = 2
  memory       = 2048
  disk_size    = 30
  image_id     = var.image_id
  vnet_id      = var.vnets.vddb
  ipv4_address = "10.20.2.12/24"
  ipv4_gateway = "10.20.2.1"

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
resource "proxmox_backup_job" "minio_dev_backup" {
  count    = var.enable_minio_dev ? 1 : 0
  id       = "backup-dev-data-minio"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.minio_dev[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
