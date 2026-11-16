variable "proxmox_endpoint" {
  description = "The Proxmox VE API endpoint URL"
  type        = string
  default     = null
}

variable "proxmox_api_token" {
  description = "The Proxmox VE API token for Atlantis (scoped to dev-app and prod-app)"
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_insecure" {
  description = "Whether to bypass TLS certificate validation"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox target cluster node"
  type        = string
  default     = "pve-01"
}

variable "image_id" {
  description = "Debian Cloud Image ID in Proxmox storage"
  type        = string
  default     = "local:import/debian-12-genericcloud-amd64.qcow2"
}

variable "ssh_public_keys" {
  description = "List of authorized public SSH keys for automation"
  type        = list(string)
  default     = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYJ2OfdEN7U4fre+GF+peMoPhZ0oQHJlwgshJWq0JWG ansible-automation",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB7FQ2ZFKOxGDUQGszwC+VM6NjaacPGlwjrXwyKbkk4 admin-operator"
  ]
}

variable "infisical_host" {
  description = "The Infisical API host endpoint"
  type        = string
  default     = "http://10.10.1.13:8080"
}

variable "infisical_workspace_id" {
  description = "The Infisical project ID for Test App"
  type        = string
  default     = "6f57e9c7-e040-4006-b685-947566650eb8"
}

variable "infisical_token" {
  description = "The Infisical machine identity token"
  type        = string
  sensitive   = true
  default     = null
}

variable "prod_postgres_gitea_actions_password" {
  description = "PostgreSQL password for gitea_actions automation account"
  type        = string
  sensitive   = true
  default     = null
}
