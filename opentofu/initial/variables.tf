variable "node_name" {
  description = "Target Proxmox node name"
  type        = string
}

variable "image_id" {
  description = "Base Debian cloud image ID"
  type        = string
}

variable "pools" {
  description = "Map of Proxmox resource pool IDs"
  type = object({
    core_coord = string
    core_app   = string
    core_data  = string
    dev_data   = string
    prod_data  = string
  })
}

variable "vnets" {
  description = "Map of SDN VNet IDs"
  type = object({
    vcoord = string
    vcore  = string
    vcdb   = string
    vddb   = string
    vpdb   = string
  })
}

variable "ssh_public_keys" {
  description = "List of authorized SSH public keys"
  type        = list(string)
  default     = []
}

variable "enable_dns" {
  description = "Enable provisioning of the Authoritative DNS server VM"
  type        = bool
  default     = true
}

variable "enable_redis_core" {
  description = "Enable provisioning of the Core Valkey / Redis cache VM"
  type        = bool
  default     = false
}

variable "enable_redis_dev" {
  description = "Enable provisioning of the Development Valkey / Redis cache VM"
  type        = bool
  default     = false
}

variable "enable_redis_prod" {
  description = "Enable provisioning of the Production Valkey / Redis cache VM"
  type        = bool
  default     = false
}

variable "enable_minio_core" {
  description = "Enable provisioning of the Core MinIO S3 object storage VM"
  type        = bool
  default     = false
}

variable "enable_minio_dev" {
  description = "Enable provisioning of the Development MinIO S3 object storage VM"
  type        = bool
  default     = false
}

variable "enable_minio_prod" {
  description = "Enable provisioning of the Production MinIO S3 object storage VM"
  type        = bool
  default     = false
}
