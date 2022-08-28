#!/bin/bash

# Script to create Ubuntu 20.04-LTS VMs in Azure
# Copyright (C) 2022 swXtch.io
# Permission to copy and modify is granted under the MIT license

if [ $# -ne 8 ]; then
    echo "Invalid number of arguments supplied."
    echo "usage: script <rg> <vnetRG> <vnetName> <subnetCtrl> <subnetData> <vm_type> <admin> <key>"
    exit -1
fi

RG=$1
vnetRG=$2
vnetName=$3
subnetCtrl=$4
subnetData=$5
vm_type=$6
admin=$7
key=$8

echo
echo "Creating Stock Ubuntu 20.04 instances of type ${vm_type}"
echo "  RG: ${RG}"
echo "  VNET: ${vnetRG}/${vnetName}[${subnetCtrl}:${subnetData}]"
echo "  ADMIN: ${admin}"
echo "  PUBLIC_KEY : ${key}"
echo
read -p "Press Y to continue:" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    az deployment group create --resource-group ${RG} --template-file arm-ubuntu-20_04-lts.json --parameters vnetRG=${vnetRG} vnetName=${vnetName} subnetCtrl=${subnetCtrl} subnetData=${subnetData} virtualMachineSize=${vm_type} adminUsername=${admin} adminPublicKey="${key}"
else
    echo "Aborting"
fi
