module "dev_postgres" {
  source = "../modules/vm"

  name         = "dev-data-postgres"
  description  = "Development PostgreSQL relational database server"
  node_name    = var.node_name
  vm_id        = 2900
  pool_id      = var.pools.dev_data
  cores        = 2
  memory       = 2048
  disk_size    = 20
  image_id     = var.image_id
  vnet_id      = var.vnets.vddb
  ipv4_address = "10.20.2.10/24"
  ipv4_gateway = "10.20.2.1"

  ssh_public_keys = var.ssh_public_keys

  firewall_rules = [
    {
      dport   = "5432"
      comment = "Allow PostgreSQL client connections"
    },
    {
      dport   = "22"
      comment = "Allow SSH management"
    }
  ]
}
