output "firewall_status" {
  description = "Proxmox firewall configuration status"
  value = {
    cluster_firewall_enabled = proxmox_virtual_environment_cluster_firewall.cluster_firewall.enabled
    node                     = var.proxmox_node
  }
}
