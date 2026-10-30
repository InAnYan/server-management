terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

# 1. Download Debian Cloud Image to import storage (pure REST API)
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name    = "debian-12-genericcloud-amd64.qcow2"
}

# 2. Test VM in Core Coordinator Network (10.10.1.0/24)
resource "proxmox_virtual_environment_vm" "testvm" {
  name        = "testvm"
  description = "Test VM in core coordinator network"
  node_name   = var.proxmox_node
  vm_id       = 1000
  pool_id     = "core"

  agent {
    enabled = true
  }

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 1024
  }

  operating_system {
    type = "l26"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
  }

  boot_order = ["virtio0"]

  network_device {
    bridge = "vcoord"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.10.1.10/24"
        gateway = "10.10.1.1"
      }
    }

    user_account {
      username = "ansible"
      keys = [
        trimspace(file("${path.root}/../../secrets/id_ansible.pub")),
        trimspace(file("${path.root}/../../secrets/id_admin.pub"))
      ]
    }
  }
}
