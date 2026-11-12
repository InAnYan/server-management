output "vm_id" {
  description = "The VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "The VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_address" {
  description = "The configured IPv4 address with subnet CIDR"
  value       = var.ipv4_address
}

output "ip" {
  description = "The IPv4 address without subnet mask"
  value       = split("/", var.ipv4_address)[0]
}
