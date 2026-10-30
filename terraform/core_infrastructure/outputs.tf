output "vm_id" {
  description = "VMID of testvm"
  value       = proxmox_virtual_environment_vm.testvm.vm_id
}

output "vm_name" {
  description = "Name of the VM"
  value       = proxmox_virtual_environment_vm.testvm.name
}

output "vm_ip" {
  description = "Static IP address configured for testvm"
  value       = "10.11.0.10"
}
