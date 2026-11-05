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
