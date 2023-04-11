provider "azurerm" {
  features {}
}



# Create a resource group
resource "azurerm_resource_group" "myresourcegroup" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "myvnet" {
  name                = "my-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

# Create a Network Security Group
resource "azurerm_network_security_group" "mynsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a subnet
resource "azurerm_subnet" "mysubnet" {
  name                 = "my-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.myvnet.name
  resource_group_name  = azurerm_resource_group.myresourcegroup.name
}
# Associate network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "my-association" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

# Create a public IP address
resource "azurerm_public_ip" "mypublicip" {
  name                = "my-public-ip"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  location            = azurerm_resource_group.myresourcegroup.location

  allocation_method = "Dynamic"

  tags = {
    environment = "dev"
  }
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name                  = "my-linux-vm"
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  location              = azurerm_resource_group.myresourcegroup.location
  size                  = var.vm_size
  admin_username        = "myadminuser"
  network_interface_ids = [azurerm_network_interface.mynic.id]
  admin_ssh_key {
    username   = "myadminuser"
    public_key = file("~/.ssh/azurekey.pub")
  }

  os_disk {
    name                 = "my-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Create a network interface
resource "azurerm_network_interface" "mynic" {
  name                = "my-network-interface"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.mypublicip.id
  }
}
