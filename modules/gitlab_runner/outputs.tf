output "gitlab_runner_vm_name" {
  value = azurerm_linux_virtual_machine.gitlab_runner.name
}

output "gitlab_runner_private_ip" {
  value = azurerm_network_interface.gitlab_runner.private_ip_address
}
