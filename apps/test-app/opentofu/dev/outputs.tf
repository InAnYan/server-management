output "vm_id" {
  description = "Virtual Machine ID for dev-app-testapp"
  value       = proxmox_virtual_environment_vm.dev_app.vm_id
}

output "vm_ip" {
  description = "Internal IP address for dev-app-testapp"
  value       = "10.21.1.10"
}
