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

locals {
  cloudswxtch_image_publisher = "swxtchiollc1614108926893"
  cloudswxtch_image_offer     = "cloudswxtch-vm-001"
  cloudswxtch_image_version   = "latest"
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

data "azurerm_resource_group" "virtualnetwork_resource_group" {
  name = var.vnet_resource_group
}

data "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.virtualnetwork_resource_group.name
}

data "azurerm_subnet" "ctrlsubnet" {
  name                 = var.ctrlsubnet_name
  resource_group_name  = data.azurerm_resource_group.virtualnetwork_resource_group.name
  virtual_network_name = data.azurerm_virtual_network.virtual_network.name
}

data "azurerm_subnet" "datasubnet" {
  name                 = var.datasubnet_name
  resource_group_name  = data.azurerm_resource_group.virtualnetwork_resource_group.name
  virtual_network_name = data.azurerm_virtual_network.virtual_network.name
}

resource "azurerm_network_interface" "control_network_interface" {
  count               = var.swxtch_count
  name                = "${var.swxtch_name}-ctrl-nic-${count.index + 1}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "cinternal"
    subnet_id                     = data.azurerm_subnet.ctrlsubnet.id
    private_ip_address_allocation = "Dynamic"
    #private_ip_address = var.controlnic_staticip
  }
}
resource "azurerm_network_interface" "data_network_interface" {
  count                         = var.swxtch_count
  name                          = "${var.swxtch_name}-data-nic-${count.index + 1}"
  location                      = data.azurerm_resource_group.resource_group.location
  resource_group_name           = data.azurerm_resource_group.resource_group.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "dinternal"
    subnet_id                     = data.azurerm_subnet.datasubnet.id
    private_ip_address_allocation = "Dynamic"
    #private_ip_address            = var.datanic_staticip
  }
}


resource "azurerm_linux_virtual_machine" "CloudSwxtch" {
  count               = var.swxtch_count
  name                = "${var.swxtch_name}-0${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.swxtch_instance_size
  admin_username      = var.admin_username
  network_interface_ids = [
    element(azurerm_network_interface.control_network_interface.*.id, count.index),
    element(azurerm_network_interface.data_network_interface.*.id, count.index)
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_public_ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = local.cloudswxtch_image_publisher
    offer     = local.cloudswxtch_image_offer
    sku       = var.swxtch_plan
    version   = local.cloudswxtch_image_version
  }

  plan {
    name      = "swxtch-small-002"
    publisher = "swxtchiollc1614108926893"
    product   = "cloudswxtch-vm-001"
  }
}
