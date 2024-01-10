variable "swxtch_count" {
  description = "The number of cloudSwXtches to deploy"
  type        = number
  default     = 1
}

variable "swxtch_name" {
  type    = string
  default = "swxtch-example"
}

variable "swxtch_instance_size" {
  description = "cloudSwXtch Instance Size"
  type        = string
  default     = "Standard_D4s_v4"
}

variable "swxtch_plan" {
  description = "The plan to use. One of: swxtch-small-003 or byol-001"
  type        = string
  default     = "swx-poc-001"

  validation {
    condition = contains(
      [
        "swx-poc-001",
        "byol-001",
    ], var.swxtch_plan)

    error_message = "Not a valid Azure cloudSwXtch plan."
  }
}

# User/auth method

variable "admin_username" {
  description = "admin user name for VM"
  type        = string
  default     = "swxtchadmin"
}

variable "admin_public_ssh_key_path" {
  description = "Path to the public ssh key, used for ssh access to the cloudswxtch"
  type        = string
}

variable "resource_group" {
  description = "Resource Group Name to deploy the cloudSwXtch in."
  type        = string
}

variable "vnet_resource_group" {
  description = "Existing Vnet Resource Group Name"
  type        = string
}

variable "vnet_name" {
  description = "Existing Virtual Network name"
  type        = string
}

variable "ctrlsubnet_name" {
  description = "Exisiting Control Subnet name"
  type        = string
}

variable "datasubnet_name" {
  description = "Exisiting data Subnet name"
  type        = string
}

#If Using Static ip address:

variable "controlnic_staticip" {
  description = "private ip address for control nic"
  type        = string
}

variable "datanic_staticip" {
  description = "private ip address for data nic"
  type        = string
}
