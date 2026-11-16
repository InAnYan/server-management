# --- Host Firewall Rules ---

resource "proxmox_virtual_environment_firewall_rules" "node_rules" {
  node_name = var.node_name

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "41641"
    comment = "Allow Tailscale daemon UDP communication"
    enabled = true
  }

  # [impl->req~host-ssh-port-2222-key-only~1]
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "2222"
    comment = "Allow SSH for host management (key-only authentication)"
    enabled = true
  }

  # [impl->req~host-access-tailscale-only~1]
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "8006"
    iface   = "tailscale0"
    source  = "100.64.0.0/10"
    comment = "Allow Proxmox Web Dashboard from Tailscale network"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "8006"
    source  = "10.10.1.12/32"
    comment = "Allow Proxmox API access for Atlantis GitOps from core-coord-gitea"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80"
    comment = "Allow HTTP for Caddy reverse proxy"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "443"
    comment = "Allow HTTPS for Caddy reverse proxy"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "53"
    comment = "Allow DNS UDP queries on host"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "53"
    comment = "Allow DNS TCP queries on host"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "22"
    comment = "Allow Git SSH for Gitea service"
    enabled = true
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "8888"
    source  = "10.0.0.0/8"
    comment = "Allow internal HTTP proxy from SDN subnets"
    enabled = true
  }
}

# [impl->req~firewall-enabled~1]
resource "proxmox_virtual_environment_cluster_firewall" "cluster_firewall" {
  enabled        = true
  input_policy   = "DROP"
  output_policy  = "ACCEPT"
  forward_policy = "DROP"

  depends_on = [
    proxmox_virtual_environment_firewall_rules.node_rules
  ]
}

resource "proxmox_node_firewall" "node_firewall" {
  node_name = var.node_name
  enabled   = true
  nftables  = true
}

# [impl->req~cross-environment-isolation~1]
# [impl->req~databases-isolated-from-internet~1]
resource "proxmox_virtual_environment_firewall_rules" "cluster_rules" {
  # --- Explicit ALLOW rules ---

  # 1. Core coordinator to all subnets
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vcore-all"
    comment = "Allow coordinator to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vcdb-all"
    comment = "Allow coordinator to core data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vdev-all"
    comment = "Allow coordinator to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vddb-all"
    comment = "Allow coordinator to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vprod-all"
    comment = "Allow coordinator to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    dest    = "+sdn/vpdb-all"
    comment = "Allow coordinator to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcoord-all"
    comment = "Allow coordinator internet egress"
    enabled = true
  }

  # 2. Core applications
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcore-all"
    dest    = "+sdn/vcdb-all"
    comment = "Allow core app to core data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vcore-all"
    comment = "Allow core app internet egress (e.g. DNS resolution)"
    enabled = true
  }

  # 3. Development environment
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vddb-all"
    comment = "Allow dev app to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vdev-all"
    comment = "Allow dev app internet egress"
    enabled = true
  }

  # 4. Production environment
  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vpdb-all"
    comment = "Allow prod app to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "+sdn/vprod-all"
    comment = "Allow prod app internet egress"
    enabled = true
  }

  # 5. Logging Ingress Exception (Allow all VMs across all tiers to ship telemetry to Loki)
  # [impl->req~centralized-logging~1]
  rule {
    type    = "forward"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "3100"
    dest    = "10.10.1.14/32"
    comment = "Logging Exception: Allow all VMs to push logs to Loki on port 3100"
    enabled = true
  }

  # --- Explicit DROP rules ---

  # Dev isolation
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vprod-all"
    comment = "Drop dev app to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vpdb-all"
    comment = "Drop dev app to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vcore-all"
    comment = "Drop dev app to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vdev-all"
    dest    = "+sdn/vcdb-all"
    comment = "Drop dev app to core data"
    enabled = true
  }

  # Prod isolation
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vdev-all"
    comment = "Drop prod app to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vddb-all"
    comment = "Drop prod app to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vcore-all"
    comment = "Drop prod app to core app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vprod-all"
    dest    = "+sdn/vcdb-all"
    comment = "Drop prod app to core data"
    enabled = true
  }

  # Database subnets isolation: no cross-environment data access, no WAN egress
  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    dest    = "+sdn/vpdb-all"
    comment = "Drop dev data to prod data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    dest    = "+sdn/vprod-all"
    comment = "Drop dev data to prod app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vddb-all"
    comment = "Drop dev data internet egress"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    dest    = "+sdn/vddb-all"
    comment = "Drop prod data to dev data"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    dest    = "+sdn/vdev-all"
    comment = "Drop prod data to dev app"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vpdb-all"
    comment = "Drop prod data internet egress"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "+sdn/vcdb-all"
    comment = "Drop core data internet egress"
    enabled = true
  }
}
