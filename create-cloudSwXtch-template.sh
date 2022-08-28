#!/bin/bash
# Script to install a template spec to create cloudSwXtch from MP offer
# Copyright (C) 2022 swXtch.io
# Permission to copy and modify is granted under the MIT license
ThisScriptVersion="1.0.0"

if [[ ($# -lt 1) || ($# -gt 2) ]]; then
    echo "Invalid number of arguments supplied."
    echo "usage: script <resource-group> [name:cloudSwXtch-template]"
    echo "    <resource-group> must exist and is where the template spec will be installed"
    echo "    [name] is the name of the template spec and is optional. Defaults to 'cloudSwXtch-from-vm-image'."
    echo "This script expects the template source files to be in the same directory."
    exit -1
fi

rg=$1
TemplateNameInAzure=${2:-cloudSwXtch-template}
vmTemplate="./TemplateVM.json"
uiTemplate="./TemplateUI.json"
templateVersion="1"

if [ ! -f "$vmTemplate" ]; then
    echo "ERROR: $vmTemplate not found."
    exit
fi
if [ ! -f "$uiTemplate" ]; then
    echo "ERROR: $vmTemplate not found."
    exit
fi

az ts create -n $TemplateNameInAzure -g $rg -v $templateVersion -f $vmTemplate --ui-form-definition $uiTemplate
