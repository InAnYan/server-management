module "prod_postgres" {
  source = "../modules/vm"

  name         = "prod-data-postgres"
  description  = "Production PostgreSQL relational database server"
  node_name    = var.node_name
  vm_id        = 3900
  pool_id      = var.pools.prod_data
  cores        = 2
  memory       = 2048
  disk_size    = 20
  image_id     = var.image_id
  vnet_id      = var.vnets.vpdb
  ipv4_address = "10.30.2.10/24"
  ipv4_gateway = "10.30.2.1"

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
