variable "node_name" {
  description = "Target Proxmox node name"
  type        = string
  default     = ""
}

variable "image_id" {
  description = "Base Debian cloud image ID"
  type        = string
  default     = ""
}

variable "pools" {
  description = "Map of Proxmox resource pool IDs"
  type        = map(string)
  default     = {}
}

variable "vnets" {
  description = "Map of SDN VNet IDs"
  type        = map(string)
  default     = {}
}

variable "ssh_public_keys" {
  description = "List of authorized SSH public keys"
  type        = list(string)
  default     = []
}
