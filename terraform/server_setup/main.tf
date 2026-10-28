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

# Base server setup resources (e.g. storage, networking, snippets, or templates)
# Example: Linux Bridge network configuration
# resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
#   node_name = var.proxmox_node
#   name      = "vmbr1"
#   address   = "10.10.10.1/24"
#   comment   = "Internal VM network bridge"
# }

# Example: Upload cloud-init snippet or cloud image
# resource "proxmox_virtual_environment_file" "debian_cloud_image" {
#   content_type = "iso"
#   datastore_id = "local"
#   node_name    = var.proxmox_node
#
#   source_file {
#     path = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
#   }
# }
