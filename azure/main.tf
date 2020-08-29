# Define the Provider and version number
provider "azurerm" {
  version = "=2.1.0"
  features {}
}

resource "azurerm_resource_group" "RESOURCE GROUP NAME" {
  name     = var.azure_resource_group
  location = var.location
}

# Create a Storage account for storing the Backend State File 
resource "azurerm_storage_account" "terraform_storageaccount" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.RESOURCE GROUP NAME.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

resource "azurerm_storage_container" "terraform_storagecontainer" {
  name                  = var.storage_container
  resource_group_name   = azurerm_resource_group.RESOURCE GROUP NAME.name
  storage_account_name  = azurerm_storage_account.terraform_storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "terraform_blob" {
  name                   = var.blob_name
  resource_group_name    = azurerm_resource_group.RESOURCE GROUP NAME.name
  storage_account_name   = azurerm_storage_account.terraform_storageaccount.name
  storage_container_name = azurerm_storage_container.terraform_storagecontainer.name
  type                   = "block"
}

#Make sure that the Storage account is created first before initializing this below
terraform {
  backend "azurerm" {
    resource_group_name  = azurerm_resource_group.RESOURCE GROUP NAME.name
    storage_account_name = azurerm_storage_account.terraform_storageaccount.name
    container_name       = azurerm_storage_container.terraform_storagecontainer.name
    key                  = var.blob_name
  }
}