module "gitea" {
  source = "../modules/vm"

  name         = "core-coord-gitea"
  description  = "Gitea self-hosted Git repository and collaboration platform"
  node_name    = var.node_name
  vm_id        = 1200
  pool_id      = var.pools.core_coord
  cores        = 2
  memory       = 2048
  disk_size    = 20
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.12/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "3000"
      comment = "Allow Gitea Web UI and HTTP API"
    },
    {
      dport   = "2222"
      comment = "Allow Gitea SSH git operations"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "gitea_backup" {
  id       = "backup-core-coord-gitea"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.gitea.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
