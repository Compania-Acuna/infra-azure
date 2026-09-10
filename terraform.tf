locals {
  idapp = "jacuna" # Identificador del alumno
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "edfe8ae6-6538-4820-807d-cf67d0c18369" # Id de suscripción
}
