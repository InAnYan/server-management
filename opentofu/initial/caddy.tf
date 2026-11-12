module "caddy" {
  source = "../modules/vm"

  name         = "core-coord-caddy"
  description  = "Caddy reverse proxy and ingress coordinator"
  node_name    = var.node_name
  vm_id        = 1000
  pool_id      = var.pools.core_coord
  image_id     = var.image_id
  vnet_id      = var.vnets.vcoord
  ipv4_address = "10.10.1.10/24"
  ipv4_gateway = "10.10.1.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "80"
      comment = "Allow HTTP inbound"
    },
    {
      dport   = "443"
      comment = "Allow HTTPS inbound"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "caddy_backup" {
  id       = "backup-core-coord-caddy"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.caddy.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
