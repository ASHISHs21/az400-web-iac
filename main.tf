############################################
# Terraform Settings (Backend + Providers)
############################################
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaz40001"
    container_name       = "tfstate"
    key                  = "az400-web.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

############################################
# Azure Provider
############################################
provider "azurerm" {
  features {}
}

############################################
# Random ID (KEEP ORIGINAL NAME)
############################################
resource "random_id" "rand" {
  byte_length = 4
}

############################################
# Resource Group
############################################
resource "azurerm_resource_group" "rg" {
  name     = "rg-az400-iac"
  location = "Central India"
}

############################################
# App Service Plan (KEEP ORIGINAL NAME)
############################################
resource "azurerm_service_plan" "plan" {
  name                = "asp-az400"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

############################################
# Linux Web App (KEEP ORIGINAL NAME)
############################################
resource "azurerm_linux_web_app" "web" {
  name                = "az400-web-${random_id.rand.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false
  }
}
