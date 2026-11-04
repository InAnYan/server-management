locals {
  default_ssh_keys = [
    trimspace(file("${path.root}/../secrets/id_ansible.pub")),
    trimspace(file("${path.root}/../secrets/id_admin.pub"))
  ]
}

# --- Virtual Machines & Workload Infrastructure ---

module "vms" {
  source = "./vms"

  node_name = var.proxmox_node
  image_id  = proxmox_virtual_environment_download_file.debian_cloud_image.id

  pools = {
    core_coord = proxmox_virtual_environment_pool.core_coord.pool_id
    core_app   = proxmox_virtual_environment_pool.core_app.pool_id
    core_data  = proxmox_virtual_environment_pool.core_data.pool_id
    dev_data   = proxmox_virtual_environment_pool.dev_data.pool_id
    prod_data  = proxmox_virtual_environment_pool.prod_data.pool_id
  }

  vnets = {
    vcoord = proxmox_sdn_vnet.vcoord.id
    vcore  = proxmox_sdn_vnet.vcore.id
    vcdb   = proxmox_sdn_vnet.vcdb.id
    vddb   = proxmox_sdn_vnet.vddb.id
    vpdb   = proxmox_sdn_vnet.vpdb.id
  }

  ssh_public_keys = local.default_ssh_keys

  depends_on = [
    proxmox_sdn_applier.sdn_apply,
    proxmox_virtual_environment_pool.core_coord,
    proxmox_virtual_environment_pool.core_app,
    proxmox_virtual_environment_pool.core_data,
    proxmox_virtual_environment_pool.dev_data,
    proxmox_virtual_environment_pool.prod_data
  ]
}
