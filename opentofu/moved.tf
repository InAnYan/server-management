# --- Virtual Machine State Migrations ---

moved {
  from = proxmox_virtual_environment_vm.caddy
  to   = module.vms.module.caddy.proxmox_virtual_environment_vm.this
}

moved {
  from = module.caddy.proxmox_virtual_environment_vm.this
  to   = module.vms.module.caddy.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.uptimekuma
  to   = module.vms.module.uptimekuma.proxmox_virtual_environment_vm.this
}

moved {
  from = module.uptimekuma.proxmox_virtual_environment_vm.this
  to   = module.vms.module.uptimekuma.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.gitea
  to   = module.vms.module.gitea.proxmox_virtual_environment_vm.this
}

moved {
  from = module.gitea.proxmox_virtual_environment_vm.this
  to   = module.vms.module.gitea.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.technitium
  to   = module.vms.module.technitium.proxmox_virtual_environment_vm.this
}

moved {
  from = module.technitium.proxmox_virtual_environment_vm.this
  to   = module.vms.module.technitium.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.postgres
  to   = module.vms.module.postgres.proxmox_virtual_environment_vm.this
}

moved {
  from = module.postgres.proxmox_virtual_environment_vm.this
  to   = module.vms.module.postgres.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.dev_postgres
  to   = module.vms.module.dev_postgres.proxmox_virtual_environment_vm.this
}

moved {
  from = module.dev_postgres.proxmox_virtual_environment_vm.this
  to   = module.vms.module.dev_postgres.proxmox_virtual_environment_vm.this
}

moved {
  from = proxmox_virtual_environment_vm.prod_postgres
  to   = module.vms.module.prod_postgres.proxmox_virtual_environment_vm.this
}

moved {
  from = module.prod_postgres.proxmox_virtual_environment_vm.this
  to   = module.vms.module.prod_postgres.proxmox_virtual_environment_vm.this
}

# --- VM Firewall Rules State Migrations ---

moved {
  from = proxmox_virtual_environment_firewall_rules.caddy_rules
  to   = module.vms.module.caddy.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.caddy.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.caddy.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.uptimekuma_rules
  to   = module.vms.module.uptimekuma.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.uptimekuma.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.uptimekuma.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.gitea_rules
  to   = module.vms.module.gitea.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.gitea.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.gitea.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.technitium_rules
  to   = module.vms.module.technitium.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.technitium.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.technitium.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.postgres_rules
  to   = module.vms.module.postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.postgres.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.dev_postgres_rules
  to   = module.vms.module.dev_postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.dev_postgres.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.dev_postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = proxmox_virtual_environment_firewall_rules.prod_postgres_rules
  to   = module.vms.module.prod_postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

moved {
  from = module.prod_postgres.proxmox_virtual_environment_firewall_rules.this[0]
  to   = module.vms.module.prod_postgres.proxmox_virtual_environment_firewall_rules.this[0]
}

# --- VM Backup Jobs State Migrations ---

moved {
  from = proxmox_backup_job.caddy_backup
  to   = module.vms.proxmox_backup_job.caddy_backup
}

moved {
  from = proxmox_backup_job.uptimekuma_backup
  to   = module.vms.proxmox_backup_job.uptimekuma_backup
}

moved {
  from = proxmox_backup_job.gitea_backup
  to   = module.vms.proxmox_backup_job.gitea_backup
}

moved {
  from = proxmox_backup_job.technitium_backup
  to   = module.vms.proxmox_backup_job.technitium_backup
}
