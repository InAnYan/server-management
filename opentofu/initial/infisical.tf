# [impl->req~provisioning-opentofu~1]
# [impl->req~secrets-management-platform~1]
module "infisical" {
  source = "../modules/vm"

  name         = "core-coord-infisical"
  description  = "Infisical self-hosted secret management platform"
  node_name    = var.node_name
  vm_id        = 1300
  pool_id      = var.pools.core_coord
  cores        = 2
  memory       = 2048
  disk_size    = 20
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.13/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "8080"
      comment = "Allow Infisical HTTP API and Web UI"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

# [impl->req~backups-opentofu~1]
resource "proxmox_backup_job" "infisical_backup" {
  id       = "backup-core-coord-infisical"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.infisical.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
