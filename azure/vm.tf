resource "azurerm_linux_virtual_machine" "VM" {
  name                            = "VM NAME"
  resource_group_name             = azurerm_resource_group.RESOURCE GROUP NAME.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  location                        = var.location
  size                            = "Standard_E2s_v3"
  computer_name                   = "Computer Name / Hostname"
  disable_password_authentication = true
  admin_username                  = "azureroot"

  admin_ssh_key {
    username = "azureroot"
    public_key = file("~/.ssh/id_rsa.pub") # you can either load a file, or paste the contents to your public key here
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }
}

# Creates an extra Disk
resource "azurerm_managed_disk" "VM-disk" {
  disk_size_gb         = 100
  resource_group_name  = azurerm_resource_group.RESOURCE GROUP NAME.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  name                 = "${azurerm_linux_virtual_machine.VM.name}-disk"
  location             = var.location
}

# Attach this Disk to your Virtual Machine
resource "azurerm_virtual_machine_data_disk_attachment" "VM-disk-attach" {
  managed_disk_id    = azurerm_managed_disk.VM-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.VM.id
  lun                = 0
  caching            = "ReadWrite"
}

