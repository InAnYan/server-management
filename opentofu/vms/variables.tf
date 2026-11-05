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

variable "enable_technitium" {
  description = "Enable provisioning of the Technitium DNS server VM"
  type        = bool
  default     = true
}
