terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "sonarqube" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "sonarqube" {
  name                = "vnet-sonarqube"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sonarqube.location
  resource_group_name = azurerm_resource_group.sonarqube.name
}

# Subnet
resource "azurerm_subnet" "sonarqube" {
  name                 = "subnet-sonarqube"
  resource_group_name  = azurerm_resource_group.sonarqube.name
  virtual_network_name = azurerm_virtual_network.sonarqube.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "sonarqube" {
  name                = "pip-sonarqube"
  location            = azurerm_resource_group.sonarqube.location
  resource_group_name = azurerm_resource_group.sonarqube.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "sonarqube" {
  name                = "nsg-sonarqube"
  location            = azurerm_resource_group.sonarqube.location
  resource_group_name = azurerm_resource_group.sonarqube.name

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

  security_rule {
    name                       = "SonarQube"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "sonarqube" {
  name                = "nic-sonarqube"
  location            = azurerm_resource_group.sonarqube.location
  resource_group_name = azurerm_resource_group.sonarqube.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sonarqube.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonarqube.id
  }
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "sonarqube" {
  network_interface_id      = azurerm_network_interface.sonarqube.id
  network_security_group_id = azurerm_network_security_group.sonarqube.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "sonarqube" {
  name                            = "vm-sonarqube"
  resource_group_name             = azurerm_resource_group.sonarqube.name
  location                        = azurerm_resource_group.sonarqube.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.sonarqube.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/scripts/init.sh"))

  tags = {
    Environment = "Production"
    Project     = "AromaLife"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "sonarqube_public_ip" {
  description = "Public IP address of the SonarQube VM"
  value       = azurerm_public_ip.sonarqube.ip_address
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${azurerm_public_ip.sonarqube.ip_address}:9000"
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.sonarqube.ip_address}"
}

output "vm_credentials" {
  description = "VM login credentials"
  value = {
    username = var.admin_username
    password = var.admin_password
  }
  sensitive = true
}
