terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = var.description
  node_name   = var.node_name
  vm_id       = var.vm_id
  pool_id     = var.pool_id
  protection  = var.protection

  agent {
    enabled = true
    timeout = "0s"
  }

  cpu {
    cores = var.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
    import_from  = var.image_id
  }

  boot_order = ["scsi0"]

  serial_device {}

  vga {
    type = "serial0"
  }

  network_device {
    bridge   = var.vnet_id
    model    = "virtio"
    firewall = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    # [impl->req~vm-access-ssh-keys-only~1]
    user_account {
      username = var.user_account_username
      keys     = var.ssh_public_keys
    }
  }
}

resource "proxmox_virtual_environment_firewall_rules" "this" {
  count = length(var.firewall_rules) > 0 ? 1 : 0

  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.this.vm_id

  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      type           = coalesce(rule.value.type, "in")
      action         = coalesce(rule.value.action, "ACCEPT")
      proto          = rule.value.proto
      dport          = rule.value.dport
      sport          = rule.value.sport
      source         = rule.value.source
      dest           = rule.value.dest
      iface          = rule.value.iface
      comment        = rule.value.comment
      enabled        = coalesce(rule.value.enabled, true)
      log            = rule.value.log
      macro          = rule.value.macro
      security_group = rule.value.security_group
    }
  }
}
