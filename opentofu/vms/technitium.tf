module "technitium" {
  source = "../modules/vm"

  name         = "core-app-technitium"
  description  = "Technitium DNS server and internal name resolution"
  node_name    = var.node_name
  vm_id        = 1500
  pool_id      = var.pools.core_app
  image_id     = var.image_id
  vnet_id      = var.vnets.vcore
  ipv4_address = "10.11.0.10/16"
  ipv4_gateway = "10.11.0.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      proto   = "udp"
      dport   = "53"
      comment = "Allow DNS UDP queries"
    },
    {
      proto   = "tcp"
      dport   = "53"
      comment = "Allow DNS TCP queries"
    },
    {
      dport   = "80"
      comment = "Allow HTTP Web UI dashboard"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "technitium_backup" {
  id       = "backup-core-app-technitium"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.technitium.vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
