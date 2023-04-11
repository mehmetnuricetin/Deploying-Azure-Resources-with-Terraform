

# Variables
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to create."
  default     = "my-resource-group"
}

variable "location" {
  type        = string
  description = "The Azure location to create resources in."
  default     = "eastus"
}



variable "vm_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_B2ms"
}

