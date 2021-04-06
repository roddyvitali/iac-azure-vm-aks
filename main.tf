// 1. create virtual machine to install jenkins
resource "azurerm_resource_group" "resource_group_vm" {
  name        = var.name
  location    = var.location
}

resource "azurerm_public_ip" "publicip" {
  name                        = "rvitali-ip"
  resource_group_name         = azurerm_resource_group.resource_group_vm.name
  location                    = azurerm_resource_group.resource_group_vm.location
  allocation_method           = "Static"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                        = "rvitali-vnetwork"
  address_space               = ["32.0.0.0/16"]
  resource_group_name         = azurerm_resource_group.resource_group_vm.name
  location                    = azurerm_resource_group.resource_group_vm.location
}

resource "azurerm_subnet" "subnet_internal" {
  name                        = "rvitali-subnet"
  resource_group_name         = azurerm_resource_group.resource_group_vm.name
  virtual_network_name        = azurerm_virtual_network.virtual_network.name
  address_prefixes            = ["32.0.2.0/24"]
}

resource "azurerm_network_interface" "network_interface" {
  name                = "rvitali-interface"
  location            = azurerm_resource_group.resource_group_vm.location
  resource_group_name = azurerm_resource_group.resource_group_vm.name

  ip_configuration {
    name                          = "rvitali-cip"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
resource "azurerm_linux_virtual_machine" "virtual-machine" {
  name                = "rvitali-virtual-machine"
  resource_group_name = azurerm_resource_group.resource_group_vm.name
  location            = azurerm_resource_group.resource_group_vm.location
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name = "hostname"
  admin_username = var.vm_username
  admin_password = var.vm_password

  disable_password_authentication = false
}

// 2. create cluster kubernetes
resource "azurerm_resource_group" "resource_group_aks" {
  name        = var.name_aks
  location    = var.location_aks
}
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "rvitali-aks"
  location            = azurerm_resource_group.resource_group_aks.location
  resource_group_name = azurerm_resource_group.resource_group_aks.name
  dns_prefix          = "rvitaliaks1"
  kubernetes_version  = "1.19.6"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    max_pods            = 80
    max_count           = 3
    min_count           = 1
  }

  service_principal {
    client_id             = var.client_id
    client_secret         = var.client_secret
  }

  network_profile {
    network_plugin        = "azure"
    network_policy        = "azure"
  }

  role_based_access_control {
    enabled               = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  max_pods              = 80
  node_labels = {
    label: "Adicional"
  }
  tags = {
    label = "Tag - Adicional"
  }
}

// General
variable "name" { }
variable "location" { }
variable "name_aks" { }
variable "location_aks" { }
variable "client_id" { }
variable "client_secret" { }
variable "subscription_id" { }
variable "tenant_id" { }
// Definitions for VM
variable "vm_username" { }
variable "vm_password" { }