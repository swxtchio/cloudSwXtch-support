variable "swxtch_count" {
  description = "The number of cloudSwXtches to deploy"
  type        = number
  default     = 1
}

variable "swxtch_plan" {
  type        = string
  description = "One of small, medium, or large"

  validation {
    condition     = var.swxtch_plan == "small" || var.swxtch_plan == "medium" || var.swxtch_plan == "large"
    error_message = "swxtch_plan must be one of small, medium, or large"
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type for the swxtch"
}

variable "swxtch_name" {
  type    = string
  default = "swxtch-example"
}

variable "swxtch_version" {
  type        = string
  default     = "latest"
  description = "The cloudswXtch version to install after deploy."
}

variable "region" {
  type = string
}

variable "data_subnet_id" {
  type        = string
  description = "Subnet ID for the data plane."
}

variable "control_subnet_id" {
  type        = string
  description = "Subnet ID for the control plane."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID that the data and control subnets are in."
}

variable "aws_ssh_key_name" {
  description = "AWS SSH keypair name to launch the swXtches with for SSH access."
}
