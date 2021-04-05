output "publicip" {
    value = azurerm_public_ip.publicip.ip_address
}

output "username" {
    value = azurerm_linux_virtual_machine.virtual-machine.admin_username
}

output "password" {
    value = azurerm_linux_virtual_machine.virtual-machine.admin_password
}