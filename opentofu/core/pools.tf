# --- Resource Pools ---
# [impl->req~environments-core-dev-prod~1]

resource "proxmox_virtual_environment_pool" "core_coord" {
  pool_id = "core-coord"
  comment = "Core coordinator workloads (Caddy, Gatus, Authentik)"
}

resource "proxmox_virtual_environment_pool" "core_app" {
  pool_id = "core-app"
  comment = "Core application workloads (PowerDNS)"
}

resource "proxmox_virtual_environment_pool" "core_data" {
  pool_id = "core-data"
  comment = "Core data and database persistence workloads"
}

# [impl->req~gitops-api-permissions-minimal~1]
resource "proxmox_virtual_environment_pool" "dev_app" {
  pool_id = "dev-app"
  comment = "Development application workloads"
}

resource "proxmox_virtual_environment_pool" "dev_data" {
  pool_id = "dev-data"
  comment = "Development data and database persistence workloads"
}

# [impl->req~gitops-api-permissions-minimal~1]
resource "proxmox_virtual_environment_pool" "prod_app" {
  pool_id = "prod-app"
  comment = "Production application workloads"
}

resource "proxmox_virtual_environment_pool" "prod_data" {
  pool_id = "prod-data"
  comment = "Production data and database persistence workloads"
}
