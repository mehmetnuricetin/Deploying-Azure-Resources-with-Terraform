


output "vm_public_ip_address" {
  value = azurerm_linux_virtual_machine.mylinuxvm.public_ip_address
  description = "The public IP address of the Linux virtual machine."
}


