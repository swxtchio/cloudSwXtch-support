variable "project_id" {
  description = "The ID of the project to deploy the cloudswXtch into."
  type        = string
}

variable "zone" {
  description = "The zone to deploy the cloudswXtch to."
  default     = "us-central1-a"
  type        = string
}

variable "name" {
  description = "The name of the deployment and VM instance."
  type        = string
}

variable "ctrl_subnet_id" {
  description = "The ID of the subnet to use for the control plane for the cloudswXtch."
  type        = string
}

variable "data_subnet_id" {
  description = "The ID of the subnet to use for the data plane for the cloudswXtch."
  type        = string
}

variable "swxtch_image_id" {
  default     = "cloudswxtch-2-0-34-2023-09-27"
  description = "The image name for the cloudswXtch VM instance."
  type        = string
}

variable "swxtch_version" {
  type        = string
  default     = "latest"
  description = "The cloudswXtch version to install after deploy."
}

variable "swxtch_machine_type" {
  default     = "n2-standard-16"
  description = "The machine type to use for the cloudswXtch VM."
  type        = string
}

variable "swxtch_count" {
  description = "The number of cloudSwXtches to deploy"
  type        = number
  default     = 1

  validation {
    condition = var.swxtch_count >= 1

    error_message = "Must deploy at least one cloudswXtch."
  }
}

variable "ssh_user" {}
variable "ssh_public_key" {}
