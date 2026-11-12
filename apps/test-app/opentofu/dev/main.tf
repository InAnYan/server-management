terraform {
  required_version = ">= 1.6.0"

  backend "http" {
    address        = "http://server:3000/api/packages/test/terraform/state/dev"
    lock_address   = "http://server:3000/api/packages/test/terraform/state/dev/lock"
    unlock_address = "http://server:3000/api/packages/test/terraform/state/dev/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.27.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token
}

provider "infisical" {
  host = var.infisical_host
  auth = {
    token = var.infisical_token
  }
}

data "infisical_secrets" "app_secrets" {
  env_slug     = "dev"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}

provider "postgresql" {
  host     = "10.20.2.10"
  port     = 5432
  database = "postgres"
  username = "gitea_actions"
  password = var.dev_postgres_gitea_actions_password
  sslmode  = "disable"
}

resource "postgresql_role" "test_app_user" {
  name     = "test_app_user"
  login    = true
  password = data.infisical_secrets.app_secrets.secrets["POSTGRES_PASSWORD"].value
}

resource "postgresql_database" "test_app" {
  name  = "test_app"
  owner = postgresql_role.test_app_user.name
}

resource "postgresql_grant" "test_app_user_all" {
  database    = postgresql_database.test_app.name
  role        = postgresql_role.test_app_user.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["ALL"]
}

resource "proxmox_virtual_environment_vm" "dev_app" {
  name        = "dev-app-testapp"
  description = "Development instance of test-app v0.3.0 managed by Atlantis"
  node_name   = var.proxmox_node
  vm_id       = 2100
  pool_id     = "dev-app"

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
    size         = 15
    import_from  = var.image_id
  }

  boot_order = ["scsi0"]

  serial_device {}

  network_device {
    bridge = "vdev"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.21.1.10/16"
        gateway = "10.21.0.1"
      }
    }

    user_account {
      username = "ansible"
      keys     = var.ssh_public_keys
    }
  }
}

resource "proxmox_virtual_environment_firewall_rules" "dev_rules" {
  node_name = var.proxmox_node
  vm_id     = proxmox_virtual_environment_vm.dev_app.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "22"
    comment = "Allow SSH management"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80"
    comment = "Allow Test App HTTP ingress"
    enabled = true
  }
}
