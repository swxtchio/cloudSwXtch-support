# cloudSwXtch-support
Support files for cloudSwXtch
These scripts make it wasy to create the VM that is needed to run cloudSwXtch.

`create-cloudSwXtch-vm.sh` - basic cloudSwXtch VM
`create-cloudSwXtch-vm-aset.sh` - supports 

### Usage

`./script <name> <rg> <vnetRG> <vnetName> <subnetCtrl> <subnetData> <vm_type> <user> "<key>"`

| Field      | Description |
| ----------- | ----------- |
| name | Name of the VM (must match linux host name rules) |
| rg | Resrouce group in which the VM will be placed |
| vnetRG | Resrouce group of the virtual network |
| vnetName | Name of the virtual network |
| subnetCtrl | Subnet of the default network interface |
| subnetData | Subnet used for switch data |
| vm_type | Full VM type name. `Standard_Dxx_vx` |
| user | Admin user account to be created on the VM |
| key | SSH public key for the user account. Wrap in quotes |
| availabilitySet | Valid only for the `-aset` script to assign an availablity set to the VM |

Example:
```
./create-cloudSwXtch-vm.sh switch001 test-rg VNetRG vnet-name subnet-ctrl subnet-data Standard_D4s_v4 admin "public key"
```
