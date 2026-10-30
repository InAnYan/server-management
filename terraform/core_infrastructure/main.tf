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

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name    = "debian-12-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "caddy" {
  name        = "core-coord-caddy"
  description = "Caddy reverse proxy and ingress coordinator"
  node_name   = var.proxmox_node
  vm_id       = 1000
  pool_id     = "host-managed"
  protection  = true

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
    bridge   = "vcoord"
    model    = "virtio"
    firewall = true
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

resource "proxmox_virtual_environment_firewall_rules" "caddy_rules" {
  node_name = var.proxmox_node
  vm_id     = proxmox_virtual_environment_vm.caddy.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80"
    comment = "Allow HTTP inbound"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "443"
    comment = "Allow HTTPS inbound"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "22"
    comment = "Allow SSH management"
    enabled = true
  }
}

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
