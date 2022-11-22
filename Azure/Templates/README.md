# Azure templates
These templates are designed to create a cloudSwXtch from a VM Image that resides in an Image Gallery.  Normally you would use the Azure Marketplace to create cloudSwXtch instances. In special circumstances you may not be able to use the marketplace and may need to deploy from a **local** copy of the cloudSwXtch VM Image.

To use these tempaltes, you must have a VM Image for cloudSwXtch in an Azure Image Gallery in your tenant. The source for the VM Image is a VHD file. You can request the VHD file from swXtch.io and the file must be placed in a storage account (blob store) in your tenant.

## Create an Image Gallery

https://learn.microsoft.com/en-us/azure/virtual-machines/create-gallery?tabs=portal%2Cportaldirect%2Ccli2

## Import a cloudSwXtch VHD file into the Image Gallery

The easiest way is via the Azure Portal GUI. Find your Image Gallery and click through to the "VM Image Definition". Select "Add Version".

* Set the "Version Number" to match that of the image you are importing.
* Select "Storage Blob (VHDs) as the **Source**.
* Select the VHD file you wish to import into the image gallery.
* There is no data disk with cloudSwXtch VHD files so leave these settings (LUN) at their default.
* Set replication as needed for your application.

## Install template into the Azure Portal

Once the VHD file is in the image gallery, there are several ways to create a VM from the image. Using the templates in this directory is the best way as they ensure correct setup. The proceedure here will install the template into a resource group in your Azure subscription. You only have to do this once and then you can use the template in the Portal to provide a GUI to create cloudSwXtches.

1. Log into the Azure Portal
2. Pick a resource group to hold the template. You can use an existing group or create a new one.
3. Launch the Azure cloud shell (https://learn.microsoft.com/en-us/azure/cloud-shell/overview)
4. Run the following commands. Replace <your-rg-here> with the name of the resouce group from step #2.


```
rg="<your-rg-here>"
git clone https://github.com/swxtchio/swx-cloudSwXtch-support
cd swx-cloudSwXtch-support
az ts create -n cloudSwxtch-from-vm-image -g $rg -v 1 -f AzureImageGalleryTemplateVM.json --ui-form-definition AzureImageGalleryTemplateUI.json
```

## Using the template

Using the template once it has been installed to your subscription is easy. Within the Azure Portal navigate to the template and choose **Deploy**.

1. Log into the Azure Portal
2. Navigate to the template
   - Find the resource group holding the template then select the template
   - Or, use the "Search resource, services, and docs" bar (G+/) and enter "cloudSwxtch-from-vm-image" in the search. This will take to directly to the template. Select the template.
3. Click "Deploy" to launch the template UI
