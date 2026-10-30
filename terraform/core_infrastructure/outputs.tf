output "caddy_vm_id" {
  description = "VMID of core-coord-caddy"
  value       = proxmox_virtual_environment_vm.caddy.vm_id
}

output "caddy_vm_name" {
  description = "Name of the Caddy VM"
  value       = proxmox_virtual_environment_vm.caddy.name
}

output "caddy_vm_ip" {
  description = "Static IP address configured for core-coord-caddy"
  value       = "10.10.1.10"
}

output "vm_id" {
  description = "VMID of core-app-testvm"
  value       = proxmox_virtual_environment_vm.testvm.vm_id
}

output "vm_name" {
  description = "Name of the VM"
  value       = proxmox_virtual_environment_vm.testvm.name
}

output "vm_ip" {
  description = "Static IP address configured for core-app-testvm"
  value       = "10.11.0.10"
}
