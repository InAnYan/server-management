variable "proxmox_endpoint" {
  description = "The Proxmox VE API endpoint URL (e.g. https://192.168.1.100:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "The Proxmox VE API token in format USER@REALM!TOKENID=UUID"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Whether to skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "The target Proxmox node name"
  type        = string
  default     = "lserver"
}

variable "enable_technitium" {
  description = "Enable provisioning of the Technitium DNS server VM and backup job"
  type        = bool
  default     = true
}

variable "enable_redis_core" {
  description = "Enable provisioning of the Core Valkey / Redis cache VM and backup job"
  type        = bool
  default     = false
}

variable "enable_redis_dev" {
  description = "Enable provisioning of the Development Valkey / Redis cache VM and backup job"
  type        = bool
  default     = false
}

variable "enable_redis_prod" {
  description = "Enable provisioning of the Production Valkey / Redis cache VM and backup job"
  type        = bool
  default     = false
}

variable "enable_minio_core" {
  description = "Enable provisioning of the Core MinIO S3 object storage VM and backup job"
  type        = bool
  default     = false
}

variable "enable_minio_dev" {
  description = "Enable provisioning of the Development MinIO S3 object storage VM and backup job"
  type        = bool
  default     = false
}

variable "enable_minio_prod" {
  description = "Enable provisioning of the Production MinIO S3 object storage VM and backup job"
  type        = bool
  default     = false
}
