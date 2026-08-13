output "resource_group_id" {
  value = azurerm_resource_group.this.id
}


output "vnet_id" {
  value = azurerm_virtual_network.this.id
}


output "subnet_id" {
  value = azurerm_subnet.this.id
}