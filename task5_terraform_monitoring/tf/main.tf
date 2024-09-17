resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resource_group_location
  name                = var.kluster_name
  resource_group_name = var.resource_group_name
  dns_prefix          = var.kluster_name
  node_resource_group = var.resource_group_name_node_pool

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = true
}

data "azurerm_user_assigned_identity" "agentpool_identity" {
  name                = "${azurerm_kubernetes_cluster.k8s.name}-agentpool"
  resource_group_name = var.resource_group_name_node_pool
  depends_on          = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_role_assignment" "kubernetes_acr_access" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  principal_id         = data.azurerm_user_assigned_identity.agentpool_identity.principal_id
}
