output "firewall_status" {
  description = "Proxmox cluster firewall status and applied host"
  value = {
    cluster_firewall_enabled = proxmox_virtual_environment_cluster_firewall.cluster_firewall.enabled
    node                     = var.proxmox_node
  }
}

output "resource_pools" {
  description = "Proxmox resource pools created"
  value = {
    core_coord = proxmox_virtual_environment_pool.core_coord.pool_id
    core_app   = proxmox_virtual_environment_pool.core_app.pool_id
    core_data  = proxmox_virtual_environment_pool.core_data.pool_id
    dev_app    = proxmox_virtual_environment_pool.dev_app.pool_id
    dev_data   = proxmox_virtual_environment_pool.dev_data.pool_id
    prod_app   = proxmox_virtual_environment_pool.prod_app.pool_id
    prod_data  = proxmox_virtual_environment_pool.prod_data.pool_id
  }
}

output "sdn_vnets" {
  description = "Proxmox SDN VNets created"
  value = {
    core_coordinator = proxmox_sdn_vnet.vcoord.id
    core_apps        = proxmox_sdn_vnet.vcore.id
    core_databases   = proxmox_sdn_vnet.vcdb.id
    dev_apps         = proxmox_sdn_vnet.vdev.id
    dev_databases    = proxmox_sdn_vnet.vddb.id
    prod_apps        = proxmox_sdn_vnet.vprod.id
    prod_databases   = proxmox_sdn_vnet.vpdb.id
  }
}
