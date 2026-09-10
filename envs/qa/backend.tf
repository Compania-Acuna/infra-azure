terraform {
  backend "azurerm" {
    resource_group_name  = "rg-cicd-terraform-app-jacuna"
    storage_account_name = "tfstatejacuna"
    container_name       = "tfstate"
    key                  = "qa/terraform.tfstate"
  }
}
