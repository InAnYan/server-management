# --- Workload Module Migration ---

moved {
  from = module.vms
  to   = module.initial
}

# --- Service Replacement Migrations ---

moved {
  from = module.initial.module.uptimekuma
  to   = module.initial.module.gatus
}

moved {
  from = module.initial.proxmox_backup_job.uptimekuma_backup
  to   = module.initial.proxmox_backup_job.gatus_backup
}

moved {
  from = module.initial.module.technitium
  to   = module.initial.module.dns
}

moved {
  from = module.initial.proxmox_backup_job.technitium_backup
  to   = module.initial.proxmox_backup_job.dns_backup
}

# --- Core Platform Resource Migrations ---

moved {
  from = proxmox_virtual_environment_download_file.debian_cloud_image
  to   = module.core.proxmox_virtual_environment_download_file.debian_cloud_image
}

moved {
  from = proxmox_backup_job.core_data_backup
  to   = module.core.proxmox_backup_job.core_data_backup
}

moved {
  from = proxmox_backup_job.dev_data_backup
  to   = module.core.proxmox_backup_job.dev_data_backup
}

moved {
  from = proxmox_backup_job.prod_data_backup
  to   = module.core.proxmox_backup_job.prod_data_backup
}

moved {
  from = proxmox_node_firewall.node_firewall
  to   = module.core.proxmox_node_firewall.node_firewall
}

moved {
  from = proxmox_virtual_environment_cluster_firewall.cluster_firewall
  to   = module.core.proxmox_virtual_environment_cluster_firewall.cluster_firewall
}

moved {
  from = proxmox_virtual_environment_firewall_rules.node_rules
  to   = module.core.proxmox_virtual_environment_firewall_rules.node_rules
}

moved {
  from = proxmox_virtual_environment_firewall_rules.cluster_rules
  to   = module.core.proxmox_virtual_environment_firewall_rules.cluster_rules
}

moved {
  from = proxmox_sdn_zone_simple.local
  to   = module.core.proxmox_sdn_zone_simple.local
}

moved {
  from = proxmox_sdn_applier.sdn_apply
  to   = module.core.proxmox_sdn_applier.sdn_apply
}

moved {
  from = proxmox_sdn_vnet.vcoord
  to   = module.core.proxmox_sdn_vnet.vcoord
}

moved {
  from = proxmox_sdn_vnet.vcore
  to   = module.core.proxmox_sdn_vnet.vcore
}

moved {
  from = proxmox_sdn_vnet.vcdb
  to   = module.core.proxmox_sdn_vnet.vcdb
}

moved {
  from = proxmox_sdn_vnet.vdev
  to   = module.core.proxmox_sdn_vnet.vdev
}

moved {
  from = proxmox_sdn_vnet.vddb
  to   = module.core.proxmox_sdn_vnet.vddb
}

moved {
  from = proxmox_sdn_vnet.vprod
  to   = module.core.proxmox_sdn_vnet.vprod
}

moved {
  from = proxmox_sdn_vnet.vpdb
  to   = module.core.proxmox_sdn_vnet.vpdb
}

moved {
  from = proxmox_sdn_subnet.vcoord_subnet
  to   = module.core.proxmox_sdn_subnet.vcoord_subnet
}

moved {
  from = proxmox_sdn_subnet.vcore_subnet
  to   = module.core.proxmox_sdn_subnet.vcore_subnet
}

moved {
  from = proxmox_sdn_subnet.vcdb_subnet
  to   = module.core.proxmox_sdn_subnet.vcdb_subnet
}

moved {
  from = proxmox_sdn_subnet.vdev_subnet
  to   = module.core.proxmox_sdn_subnet.vdev_subnet
}

moved {
  from = proxmox_sdn_subnet.vddb_subnet
  to   = module.core.proxmox_sdn_subnet.vddb_subnet
}

moved {
  from = proxmox_sdn_subnet.vprod_subnet
  to   = module.core.proxmox_sdn_subnet.vprod_subnet
}

moved {
  from = proxmox_sdn_subnet.vpdb_subnet
  to   = module.core.proxmox_sdn_subnet.vpdb_subnet
}

moved {
  from = proxmox_virtual_environment_pool.core_coord
  to   = module.core.proxmox_virtual_environment_pool.core_coord
}

moved {
  from = proxmox_virtual_environment_pool.core_app
  to   = module.core.proxmox_virtual_environment_pool.core_app
}

moved {
  from = proxmox_virtual_environment_pool.core_data
  to   = module.core.proxmox_virtual_environment_pool.core_data
}

moved {
  from = proxmox_virtual_environment_pool.dev_app
  to   = module.core.proxmox_virtual_environment_pool.dev_app
}

moved {
  from = proxmox_virtual_environment_pool.dev_data
  to   = module.core.proxmox_virtual_environment_pool.dev_data
}

moved {
  from = proxmox_virtual_environment_pool.prod_app
  to   = module.core.proxmox_virtual_environment_pool.prod_app
}

moved {
  from = proxmox_virtual_environment_pool.prod_data
  to   = module.core.proxmox_virtual_environment_pool.prod_data
}
