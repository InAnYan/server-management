output "caddy_vm_id" {
  value = module.caddy.vm_id
}

output "caddy_ip" {
  value = module.caddy.ip
}

output "uptimekuma_vm_id" {
  value = module.uptimekuma.vm_id
}

output "uptimekuma_ip" {
  value = module.uptimekuma.ip
}

output "gitea_vm_id" {
  value = module.gitea.vm_id
}

output "gitea_ip" {
  value = module.gitea.ip
}

output "technitium_vm_id" {
  value = var.enable_technitium ? module.technitium[0].vm_id : null
}

output "technitium_ip" {
  value = var.enable_technitium ? module.technitium[0].ip : null
}

output "postgres_vm_id" {
  value = module.postgres.vm_id
}

output "postgres_ip" {
  value = module.postgres.ip
}

output "dev_postgres_vm_id" {
  value = module.dev_postgres.vm_id
}

output "dev_postgres_ip" {
  value = module.dev_postgres.ip
}

output "prod_postgres_vm_id" {
  value = module.prod_postgres.vm_id
}

output "prod_postgres_ip" {
  value = module.prod_postgres.ip
}
