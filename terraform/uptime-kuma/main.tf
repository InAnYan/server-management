terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.60.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

# Example Uptime Kuma container / VM (uncomment and customize as needed)
# resource "proxmox_virtual_environment_container" "uptime_kuma" {
#   description = "Uptime Kuma Monitoring Service"
#   node_name   = var.proxmox_node
#   vm_id       = var.uptime_kuma_vmid
#
#   initialization {
#     hostname = "uptime-kuma"
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#   }
# }
