variable "name" {
  description = "Virtual machine name"
  type        = string
}

variable "description" {
  description = "Virtual machine description"
  type        = string
  default     = ""
}

variable "node_name" {
  description = "Target Proxmox node name"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID"
  type        = number
}

variable "pool_id" {
  description = "Proxmox resource pool ID"
  type        = string
}

variable "protection" {
  description = "Whether to prevent VM deletion in Proxmox"
  type        = bool
  default     = true
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "Emulated CPU type"
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Dedicated RAM in megabytes"
  type        = number
  default     = 1024
}

variable "disk_size" {
  description = "Disk size in gigabytes"
  type        = number
  default     = 10
}

variable "datastore_id" {
  description = "Target datastore ID for the root disk"
  type        = string
  default     = "local-lvm"
}

variable "image_id" {
  description = "Proxmox cloud image file ID to clone/import"
  type        = string
}

variable "vnet_id" {
  description = "SDN VNet bridge ID for network attachment"
  type        = string
}

variable "ipv4_address" {
  description = "Static IPv4 address in CIDR notation (e.g. 10.10.1.10/24)"
  type        = string
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway address"
  type        = string
}

variable "user_account_username" {
  description = "Cloud-Init initial user account username"
  type        = string
  default     = "ansible"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys authorized for the Cloud-Init user account"
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "List of firewall rules applied to this VM"
  type = list(object({
    type           = optional(string, "in")
    action         = optional(string, "ACCEPT")
    proto          = optional(string, "tcp")
    dport          = optional(string)
    sport          = optional(string)
    source         = optional(string)
    dest           = optional(string)
    iface          = optional(string)
    comment        = optional(string)
    enabled        = optional(bool, true)
    log            = optional(string)
    macro          = optional(string)
    security_group = optional(string)
  }))
  default = []
}
