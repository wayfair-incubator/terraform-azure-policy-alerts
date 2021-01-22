
provider "azurerm" {
  version = "=2.40.0"
  features {}
  subscription_id = var.subscription_id["dev"]
  tenant_id       = var.tenant_id["dev"]
  client_id       = var.client_id["dev"]
}

provider "azuread" {
  version = "=0.10.0"
  subscription_id = var.subscription_id["dev"]
  tenant_id       = var.tenant_id["dev"]
  client_id       = var.client_id["dev"]
}
provider "time" {}
