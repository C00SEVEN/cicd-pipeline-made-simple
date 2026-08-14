variable "location" {
  description = "Azure region"
  type        = string
  default     = "southafricanorth"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "rg-githubactions-company-prod"
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "vnet-githubactions-company-prod"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "snet-workloads"
}

variable "address_space" {
  type = list(string)
  default = [
    "10.10.0.0/16"
  ]
}

variable "subnet_prefix" {
  type = list(string)
  default = [
    "10.10.188.0/24"
  ]
}
