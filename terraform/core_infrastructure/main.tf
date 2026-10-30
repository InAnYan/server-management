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

# 1. Download Debian Cloud Image
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name    = "debian-12-genericcloud-amd64.img"
}

# 2. Cloud-Init Snippet for Users & SSH Keys
resource "proxmox_virtual_environment_file" "testvm_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ansible
        gecos: Ansible Automation
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(file("${path.root}/../../secrets/id_ansible.pub"))}
      - name: admin
        gecos: Admin Operator
        sudo: ALL=(ALL) ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(file("${path.root}/../../secrets/id_admin.pub"))}
    chpasswd:
      expire: false
    package_update: false
    package_upgrade: false
    EOF
    file_name = "testvm-cloud-config.yaml"
  }
}

# 3. Test VM in Core Coordinator Network (10.10.1.0/24)
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

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  boot_order = ["scsi0"]

  network_device {
    bridge = "vcoord"
    model  = "virtio"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.testvm_cloud_config.id

    ip_config {
      ipv4 {
        address = "10.10.1.10/24"
        gateway = "10.10.1.1"
      }
    }
  }
}
