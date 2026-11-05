output "caddy_vm_id" {
  description = "VM ID for core-coord-caddy"
  value       = module.vms.caddy_vm_id
}

output "caddy_vm_ip" {
  description = "IPv4 address for core-coord-caddy"
  value       = module.vms.caddy_ip
}

output "uptimekuma_vm_id" {
  description = "VM ID for core-coord-uptimekuma"
  value       = module.vms.uptimekuma_vm_id
}

output "uptimekuma_vm_ip" {
  description = "IPv4 address for core-coord-uptimekuma"
  value       = module.vms.uptimekuma_ip
}

output "gitea_vm_id" {
  description = "VM ID for core-coord-gitea"
  value       = module.vms.gitea_vm_id
}

output "gitea_vm_ip" {
  description = "IPv4 address for core-coord-gitea"
  value       = module.vms.gitea_ip
}

output "technitium_vm_id" {
  description = "VM ID for core-app-technitium"
  value       = module.vms.technitium_vm_id
}

output "technitium_vm_ip" {
  description = "IPv4 address for core-app-technitium"
  value       = module.vms.technitium_ip
}

output "postgres_vm_id" {
  description = "VM ID for core-data-postgres"
  value       = module.vms.postgres_vm_id
}

output "postgres_vm_ip" {
  description = "IPv4 address for core-data-postgres"
  value       = module.vms.postgres_ip
}

output "dev_postgres_vm_id" {
  description = "VM ID for dev-data-postgres"
  value       = module.vms.dev_postgres_vm_id
}

output "dev_postgres_vm_ip" {
  description = "IPv4 address for dev-data-postgres"
  value       = module.vms.dev_postgres_ip
}

output "prod_postgres_vm_id" {
  description = "VM ID for prod-data-postgres"
  value       = module.vms.prod_postgres_vm_id
}

output "prod_postgres_vm_ip" {
  description = "IPv4 address for prod-data-postgres"
  value       = module.vms.prod_postgres_ip
}

output "redis_core_vm_id" {
  description = "VM ID for core-data-redis"
  value       = module.vms.redis_core_vm_id
}

output "redis_core_vm_ip" {
  description = "IPv4 address for core-data-redis"
  value       = module.vms.redis_core_ip
}

output "redis_dev_vm_id" {
  description = "VM ID for dev-data-redis"
  value       = module.vms.redis_dev_vm_id
}

output "redis_dev_vm_ip" {
  description = "IPv4 address for dev-data-redis"
  value       = module.vms.redis_dev_ip
}

output "redis_prod_vm_id" {
  description = "VM ID for prod-data-redis"
  value       = module.vms.redis_prod_vm_id
}

output "redis_prod_vm_ip" {
  description = "IPv4 address for prod-data-redis"
  value       = module.vms.redis_prod_ip
}

output "minio_core_vm_id" {
  description = "VM ID for core-data-minio"
  value       = module.vms.minio_core_vm_id
}

output "minio_core_vm_ip" {
  description = "IPv4 address for core-data-minio"
  value       = module.vms.minio_core_ip
}

output "minio_dev_vm_id" {
  description = "VM ID for dev-data-minio"
  value       = module.vms.minio_dev_vm_id
}

output "minio_dev_vm_ip" {
  description = "IPv4 address for dev-data-minio"
  value       = module.vms.minio_dev_ip
}

output "minio_prod_vm_id" {
  description = "VM ID for prod-data-minio"
  value       = module.vms.minio_prod_vm_id
}

output "minio_prod_vm_ip" {
  description = "IPv4 address for prod-data-minio"
  value       = module.vms.minio_prod_ip
}
