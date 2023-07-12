admin_public_ssh_key_path = "~/path/to/your/ssh/key"

ctrlsubnet_name = "CTRL SUBNET NAME HERE"
datasubnet_name = "DATA SUBNET NAME HERE"

resource_group = "SWXTCH RESOURCE GROUP NAME HERE"

vnet_name           = "VNET NAME HERE"
vnet_resource_group = "VNET RESOURCE GROUP NAME HERE"

# Fill these in if you are using static IPs. You must also change the IP allocation
# on the `azurerm_network_interface` resources.
controlnic_staticip = ""
datanic_staticip    = ""
