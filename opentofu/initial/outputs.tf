output "caddy_vm_id" {
  value = module.caddy.vm_id
}

output "caddy_ip" {
  value = module.caddy.ip
}

output "gatus_vm_id" {
  value = module.gatus.vm_id
}

output "gatus_ip" {
  value = module.gatus.ip
}

output "gitea_vm_id" {
  value = module.gitea.vm_id
}

output "gitea_ip" {
  value = module.gitea.ip
}

output "infisical_vm_id" {
  value = module.infisical.vm_id
}

output "infisical_ip" {
  value = module.infisical.ip
}

output "logger_vm_id" {
  value = module.logger.vm_id
}

output "logger_ip" {
  value = module.logger.ip
}

output "authentik_vm_id" {
  value = module.authentik.vm_id
}

output "authentik_ip" {
  value = module.authentik.ip
}

output "dns_vm_id" {
  value = var.enable_dns ? module.dns[0].vm_id : null
}

output "dns_ip" {
  value = var.enable_dns ? module.dns[0].ip : null
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

output "redis_core_vm_id" {
  value = var.enable_redis_core ? module.redis_core[0].vm_id : null
}

output "redis_core_ip" {
  value = var.enable_redis_core ? module.redis_core[0].ip : null
}

output "redis_dev_vm_id" {
  value = var.enable_redis_dev ? module.redis_dev[0].vm_id : null
}

output "redis_dev_ip" {
  value = var.enable_redis_dev ? module.redis_dev[0].ip : null
}

output "redis_prod_vm_id" {
  value = var.enable_redis_prod ? module.redis_prod[0].vm_id : null
}

output "redis_prod_ip" {
  value = var.enable_redis_prod ? module.redis_prod[0].ip : null
}

output "minio_core_vm_id" {
  value = var.enable_minio_core ? module.minio_core[0].vm_id : null
}

output "minio_core_ip" {
  value = var.enable_minio_core ? module.minio_core[0].ip : null
}

output "minio_dev_vm_id" {
  value = var.enable_minio_dev ? module.minio_dev[0].vm_id : null
}

output "minio_dev_ip" {
  value = var.enable_minio_dev ? module.minio_dev[0].ip : null
}

output "minio_prod_vm_id" {
  value = var.enable_minio_prod ? module.minio_prod[0].vm_id : null
}

output "minio_prod_ip" {
  value = var.enable_minio_prod ? module.minio_prod[0].ip : null
}
