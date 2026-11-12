output "image_id" {
  description = "Base Debian cloud image ID"
  value       = proxmox_virtual_environment_download_file.debian_cloud_image.id
}

output "pools" {
  description = "Map of Proxmox resource pool IDs"
  value = {
    core_coord = proxmox_virtual_environment_pool.core_coord.id
    core_app   = proxmox_virtual_environment_pool.core_app.id
    core_data  = proxmox_virtual_environment_pool.core_data.id
    dev_data   = proxmox_virtual_environment_pool.dev_data.id
    dev_app    = proxmox_virtual_environment_pool.dev_app.id
    prod_data  = proxmox_virtual_environment_pool.prod_data.id
    prod_app   = proxmox_virtual_environment_pool.prod_app.id
  }
}

output "vnets" {
  description = "Map of SDN VNet IDs"
  value = {
    vcoord = proxmox_sdn_vnet.vcoord.id
    vcore  = proxmox_sdn_vnet.vcore.id
    vcdb   = proxmox_sdn_vnet.vcdb.id
    vdev   = proxmox_sdn_vnet.vdev.id
    vddb   = proxmox_sdn_vnet.vddb.id
    vprod  = proxmox_sdn_vnet.vprod.id
    vpdb   = proxmox_sdn_vnet.vpdb.id
  }
}
