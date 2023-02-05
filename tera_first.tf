# terraform {

#    #required_version = ">=0.12"

#    required_providers {
#      azurerm = {
#        source = "hashicorp/azurerm"
#        version = "2.0"
#      }
#    }
#  }

#############himanshu
#  T I P    !
#I want to add one more point here.. IF you are using multiple tf files in a folder try avoiding it as once you run a tf file the tfstate is created.. So adding providers to another file in same folder will error out as duplicate provider 
#Create the AzureRM Provider in Terraform
 provider   "azurerm"   { 
    #version = "~>2.0"
   features   {} 
 }

#Define the Azure Resource Group
resource   "azurerm_resource_group"   "rg"   { 
   name   =   "my-first-terraform-rg" 
   location   =   "northeurope" 
 }


#Define a Virtual Network and Subnet
resource   "azurerm_virtual_network"   "myvnet"   { 
   name   =   "my-vnet" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   "frontendSubnet" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.myvnet.name 
   address_prefix   =   "10.0.1.0/24" 
 }

#Define a New Public IP Address
 resource   "azurerm_public_ip"   "myvm1publicip"   { 
   name   =   "pip1" 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 }

 #Define a Network Interface for our VM
 resource   "azurerm_network_interface"   "myvm1nic"   { 
   name   =   "myvm1-nic" 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.myvm1publicip.id 
   } 
 }


 #Define the Virtual Machine
 resource   "azurerm_windows_virtual_machine"   "example"   { 
   name                    =   "myvm1"   
   location                =   "northeurope" 
   resource_group_name     =   azurerm_resource_group.rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvm1nic.id ] 
   size                    =   "Standard_B1s" 
   admin_username          =   "adminuser" 
   admin_password          =   "Password123!" 

   source_image_reference   { 
     publisher   =   "MicrosoftWindowsServer" 
     offer       =   "WindowsServer" 
     sku         =   "2019-Datacenter" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 }