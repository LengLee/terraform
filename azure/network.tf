# Creates the Virutal Network 
resource "azurerm_virtual_network" "network" {
  name                = "Network NAME"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.RESOURCE GROUP NAME.name
}

# Creates a Subnet inside the Network
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.RESOURCE GROUP NAME.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefix       = "SUBNET"

}

# Create a Public IP Static
resource "azurerm_public_ip" "VM-pub-ip" {
  name                = "VM NAME"
  location            = var.location
  resource_group_name = azurerm_resource_group.RESOURCE GROUP NAME.name
  allocation_method   = "Static"
}

# Creates a Security Group. These are default rules that will allow all access to your resources and should be changed
resource "azurerm_network_security_group" "sg" {
  name                = "Security Group"
  location            = var.location
  resource_group_name = azurerm_resource_group.RESOURCE GROUP NAME.name

  security_rule {
    name                       = "SSH"
    description                = "Allow Inbound SSH Connection"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-80-allow"
    description                = "Allow Inbound HTTP Connection"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-443-allow"
    description                = "Allow Inbound HTTPS Connection"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "Port-80-allow-out"
    description                = "Allow Outbound HTTP Connection"
    priority                   = 1006
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-443-allow-out"
    description                = "Allow Outbound HTTPS Connection"
    priority                   = 1007
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-22-allow-out"
    description                = "Allow Outbound SSH Connection"
    priority                   = 1011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Creates a Network Interface Card and associate it to your VM IP
resource "azurerm_network_interface" "VM-nic" {
  name                = "VM-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.RESOURCE GROUP NAME.name

  ip_configuration {
    name                          = "VM-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VM-pub-ip.id
  }
}

# Attache your NIC to your Security GROUP so the Rules will apply to your VM
resource "azurerm_network_interface_security_group_association" "nic-sg" {
  network_interface_id      = azurerm_network_interface.VM-nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
}
