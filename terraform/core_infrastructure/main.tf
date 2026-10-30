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

# 2. Test VM in Core Apps Network (10.11.0.0/16) in host-managed resource pool
resource "proxmox_virtual_environment_vm" "testvm" {
  name        = "core-app-testvm"
  description = "Test VM in core apps network"
  node_name   = var.proxmox_node
  vm_id       = 1500
  pool_id     = "host-managed"

  agent {
    enabled = true
    timeout = "0s"
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

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = 10
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
  }

  boot_order = ["scsi0"]

  serial_device {}

  vga {
    type = "serial0"
  }

  network_device {
    bridge = "vcore"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.11.0.10/16"
        gateway = "10.11.0.1"
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
