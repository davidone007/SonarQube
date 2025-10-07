variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-sonarqube-aromalife"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
  # Standard_D2s_v3: 2 vCPUs, 8 GB RAM
  # For production, consider Standard_D4s_v3 or larger
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM (must be complex: 12+ chars, uppercase, lowercase, number, special char)"
  type        = string
  default     = "SonarQube2024!@#"
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
