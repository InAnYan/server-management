variable "proxmox_endpoint" {
  description = "The Proxmox VE API endpoint URL (e.g., https://192.168.1.100:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "The Proxmox VE API token in format USER@REALM!TOKENID=UUID"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Whether to bypass TLS certificate validation (set true for self-signed certs)"
  type        = bool
  default     = true
}
