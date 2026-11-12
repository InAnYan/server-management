output "image_id" {
  description = "Base Debian cloud image ID"
  value       = module.core.image_id
}

output "pools" {
  description = "Map of Proxmox resource pool IDs"
  value       = module.core.pools
}

output "vnets" {
  description = "Map of SDN VNet IDs"
  value       = module.core.vnets
}

output "caddy_vm_id" {
  description = "VM ID for core-coord-caddy"
  value       = module.initial.caddy_vm_id
}

output "caddy_vm_ip" {
  description = "IPv4 address for core-coord-caddy"
  value       = module.initial.caddy_ip
}

output "gatus_vm_id" {
  description = "VM ID for core-coord-gatus"
  value       = module.initial.gatus_vm_id
}

output "gatus_vm_ip" {
  description = "IPv4 address for core-coord-gatus"
  value       = module.initial.gatus_ip
}

output "gitea_vm_id" {
  description = "VM ID for core-coord-gitea"
  value       = module.initial.gitea_vm_id
}

output "gitea_vm_ip" {
  description = "IPv4 address for core-coord-gitea"
  value       = module.initial.gitea_ip
}

output "infisical_vm_id" {
  description = "VM ID for core-coord-infisical"
  value       = module.initial.infisical_vm_id
}

output "infisical_vm_ip" {
  description = "IPv4 address for core-coord-infisical"
  value       = module.initial.infisical_ip
}

output "logger_vm_id" {
  description = "VM ID for core-coord-logger"
  value       = module.initial.logger_vm_id
}

output "logger_vm_ip" {
  description = "IPv4 address for core-coord-logger"
  value       = module.initial.logger_ip
}

output "authentik_vm_id" {
  description = "VM ID for core-coord-authentik"
  value       = module.initial.authentik_vm_id
}

output "authentik_vm_ip" {
  description = "IPv4 address for core-coord-authentik"
  value       = module.initial.authentik_ip
}

output "dns_vm_id" {
  description = "VM ID for core-app-dns"
  value       = module.initial.dns_vm_id
}

output "dns_vm_ip" {
  description = "IPv4 address for core-app-dns"
  value       = module.initial.dns_ip
}

output "postgres_vm_id" {
  description = "VM ID for core-data-postgres"
  value       = module.initial.postgres_vm_id
}

output "postgres_vm_ip" {
  description = "IPv4 address for core-data-postgres"
  value       = module.initial.postgres_ip
}

output "dev_postgres_vm_id" {
  description = "VM ID for dev-data-postgres"
  value       = module.initial.dev_postgres_vm_id
}

output "dev_postgres_vm_ip" {
  description = "IPv4 address for dev-data-postgres"
  value       = module.initial.dev_postgres_ip
}

output "prod_postgres_vm_id" {
  description = "VM ID for prod-data-postgres"
  value       = module.initial.prod_postgres_vm_id
}

output "prod_postgres_vm_ip" {
  description = "IPv4 address for prod-data-postgres"
  value       = module.initial.prod_postgres_ip
}

output "redis_core_vm_id" {
  description = "VM ID for core-data-redis"
  value       = module.initial.redis_core_vm_id
}

output "redis_core_vm_ip" {
  description = "IPv4 address for core-data-redis"
  value       = module.initial.redis_core_ip
}

output "redis_dev_vm_id" {
  description = "VM ID for dev-data-redis"
  value       = module.initial.redis_dev_vm_id
}

output "redis_dev_vm_ip" {
  description = "IPv4 address for dev-data-redis"
  value       = module.initial.redis_dev_ip
}

output "redis_prod_vm_id" {
  description = "VM ID for prod-data-redis"
  value       = module.initial.redis_prod_vm_id
}

output "redis_prod_vm_ip" {
  description = "IPv4 address for prod-data-redis"
  value       = module.initial.redis_prod_ip
}

output "minio_core_vm_id" {
  description = "VM ID for core-data-minio"
  value       = module.initial.minio_core_vm_id
}

output "minio_core_vm_ip" {
  description = "IPv4 address for core-data-minio"
  value       = module.initial.minio_core_ip
}

output "minio_dev_vm_id" {
  description = "VM ID for dev-data-minio"
  value       = module.initial.minio_dev_vm_id
}

output "minio_dev_vm_ip" {
  description = "IPv4 address for dev-data-minio"
  value       = module.initial.minio_dev_ip
}

output "minio_prod_vm_id" {
  description = "VM ID for prod-data-minio"
  value       = module.initial.minio_prod_vm_id
}

output "minio_prod_vm_ip" {
  description = "IPv4 address for prod-data-minio"
  value       = module.initial.minio_prod_ip
}
