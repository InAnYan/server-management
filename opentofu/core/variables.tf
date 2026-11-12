variable "node_name" {
  description = "Target Proxmox node name"
  type        = string
}

variable "enable_dns" {
  description = "Enable DNS firewall rules and resources"
  type        = bool
  default     = true
}
