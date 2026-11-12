terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}

# [impl->req~provisioning-opentofu~1]
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

locals {
  default_ssh_keys = [
    trimspace(file("${path.root}/../secrets/id_ansible.pub")),
    trimspace(file("${path.root}/../secrets/id_admin.pub"))
  ]
}

# --- Core Platform Infrastructure ---
module "core" {
  source = "./core"

  node_name  = var.proxmox_node
  enable_dns = var.enable_dns
}

# --- Initial Workload Virtual Machines ---
# [impl->req~feature-flags-optional-services~1]
module "initial" {
  source = "./initial"

  node_name         = var.proxmox_node
  image_id          = module.core.image_id
  pools             = module.core.pools
  vnets             = module.core.vnets
  ssh_public_keys   = local.default_ssh_keys
  enable_dns        = var.enable_dns
  enable_redis_core = var.enable_redis_core
  enable_redis_dev  = var.enable_redis_dev
  enable_redis_prod = var.enable_redis_prod
  enable_minio_core = var.enable_minio_core
  enable_minio_dev  = var.enable_minio_dev
  enable_minio_prod = var.enable_minio_prod
}

# --- Downstream Custom Virtual Machines ---
module "custom" {
  source = "./custom"

  node_name       = var.proxmox_node
  image_id        = module.core.image_id
  pools           = module.core.pools
  vnets           = module.core.vnets
  ssh_public_keys = local.default_ssh_keys
}
