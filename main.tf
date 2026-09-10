data "azurerm_resource_group" "main" {
  name = "rg-cicd-terraform-app-${local.idapp}"
}

data "azurerm_container_registry" "acr" {
  name                = "acr${local.idapp}"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_container_app_environment" "aca_env" {
  name                = "aca-env-${local.idapp}-${var.environment}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

# resource "azurerm_resource_provider_registration" "app" {
#   name = "Microsoft.App"
# }

resource "azurerm_container_app" "aca" {
  name                         = "aca-ms-${local.idapp}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "demo"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled           = true
    target_port                = 80
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }

  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
      registry
    ]
  }
  depends_on = [azurerm_container_app_environment.aca_env]
}


# Dar permisos al ACA para leer del ACR Global
resource "azurerm_role_assignment" "aca_pull_default_acr" {
  principal_id         = azurerm_container_app.aca.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}
# resource "azurerm_container_registry" "acr" {
#   name                = "acr${local.idapp}${var.environment}"
#   resource_group_name = data.azurerm_resource_group.main.name
#   location            = data.azurerm_resource_group.main.location
#   sku                 = "Basic"
#   admin_enabled       = false
# }

# Dar permisos al ACA para leer del ACR
# resource "azurerm_role_assignment" "aca_pull" {
#   principal_id         = azurerm_container_app.aca.identity[0].principal_id
#   role_definition_name = "AcrPull"
#   scope                = azurerm_container_registry.acr.id
# }

