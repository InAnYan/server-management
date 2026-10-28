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

# Example VM definition (uncomment and customize as needed)
# resource "proxmox_virtual_environment_vm" "example_vm" {
#   name        = "example-vm"
#   node_name   = var.proxmox_node
#   vm_id       = 100
#
#   cpu {
#     cores = 2
#   }
#   memory {
#     dedicated = 2048
#   }
# }
