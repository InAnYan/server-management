module "dns" {
  source = "../modules/vm"
  count  = var.enable_dns ? 1 : 0

  name         = "core-app-dns"
  description  = "Technitium Authoritative DNS Server and Web Console"
  node_name    = var.node_name
  vm_id        = 1500
  pool_id      = var.pools.core_app
  image_id     = var.image_id
  vnet_id      = var.vnets.vcore
  ipv4_address = "10.11.1.10/16"
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
      comment = "Allow PowerDNS-Admin HTTP Web UI"
    },
    {
      dport   = "8081"
      comment = "Allow PowerDNS internal REST API"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}

resource "proxmox_backup_job" "dns_backup" {
  count    = var.enable_dns ? 1 : 0
  id       = "backup-core-app-dns"
  node     = var.node_name
  schedule = "daily"
  storage  = "local"
  mode     = "snapshot"
  compress = "zstd"
  vmid     = [tostring(module.dns[0].vm_id)]

  prune_backups = {
    "keep-last" = "3"
  }
}
