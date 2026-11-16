output "vm_id" {
  description = "Virtual Machine ID for prod-app-testapp"
  value       = proxmox_virtual_environment_vm.prod_app.vm_id
}

output "vm_ip" {
  description = "Internal IP address for prod-app-testapp"
  value       = "10.32.1.10"
}
