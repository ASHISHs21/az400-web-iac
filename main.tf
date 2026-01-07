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
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-az400-iac"
  location = "Central India"
}

# -----------------------------
# App Service Plan (S1 required for slots)
# -----------------------------
resource "azurerm_service_plan" "plan" {
  name                = "asp-az400"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

# -----------------------------
# Application Insights
# -----------------------------
resource "azurerm_application_insights" "appinsights" {
  name                = "appi-az400-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# -----------------------------
# Linux Web App (Production / Blue)
# -----------------------------
resource "azurerm_linux_web_app" "web" {
  name                = "az400-web-3a9f0512"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appinsights.connection_string
  }

  site_config {}
}

# -----------------------------
# Green Deployment Slot
# -----------------------------
resource "azurerm_linux_web_app_slot" "green" {
  name           = "green"
  app_service_id = azurerm_linux_web_app.web.id

  site_config {}
}
