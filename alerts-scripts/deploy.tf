#Resource-group under which all resources will be created

resource "azurerm_resource_group" "example_resource_group" {
  name = "rg-us-policy-resource-group"
  location = var.location
}

# Automation account to run schedule job
resource "time_offset" "end_date" {
  offset_hours = 24 * 365
}
resource "azurerm_automation_account" "example_automation_account" {
  name                = "aa-us-policy-automation-account"
  location            = azurerm_resource_group.example_resource_group.location
  resource_group_name = azurerm_resource_group.example_resource_group.name
  sku_name = "Basic"
}
resource "azuread_application" "example_application" {
  name = "aa-us-policy-automation-account-ab6g4dh78895hlo3"
}

resource "azuread_application_certificate" "example_cert" {
  application_object_id = azuread_application.example_application.id
  type                  = "AsymmetricX509Cert"
  value                 = file("certificate.crt")
  end_date              = time_offset.end_date.rfc3339
}

resource "azuread_service_principal" "example_sp" {
  application_id = azuread_application.example_application.application_id

  depends_on = [
    azuread_application_certificate.example_cert,
  ]
}

resource "azuread_service_principal_certificate" "example_sp_crt" {
  service_principal_id = azuread_service_principal.example_sp.id
  type                 = "AsymmetricX509Cert"
  value                = file("certificate.crt")
  end_date             = time_offset.end_date.rfc3339
}
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.example_sp.object_id
}

resource "azurerm_automation_certificate" "example_certificate" {
  name                    = "AzureRunAsCertificate"
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name
  base64                  = filebase64("certificate.pfx")
}

resource "azurerm_automation_connection_service_principal" "example_connection" {
  name                    = "AzureRunAsConnection"
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name
  application_id          = azuread_service_principal.example_sp.application_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  subscription_id         = data.azurerm_client_config.current.subscription_id
  certificate_thumbprint  = azurerm_automation_certificate.example_certificate.thumbprint
}

#Download modules dependencies for runbook
resource "azurerm_automation_module" "example_module_1" {
  name                    = "Az.Accounts"
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name

  module_link {
    uri = "location.href='https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.2.4'"
  }
}

resource "azurerm_automation_module" "example_module_2" {
  name                    = "Az.Resources"
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Resources/3.2.0"
  }
}

resource "azurerm_automation_module" "example_module_3" {
  name                    = "Az.PolicyInsights"
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.PolicyInsights/1.4.0"
  }
}
data "local_file" "example_content" {
  filename = "${path.module}/runbook/example_runbook.ps1"
}

# Automation runbook to evaluate non-compliant resources
resource "azurerm_automation_runbook" "example_runbook" {
  name                    = "rb-us-powershell-runbook"
  location                = azurerm_resource_group.example_resource_group.location
  resource_group_name     = azurerm_resource_group.example_resource_group.name
  automation_account_name = azurerm_automation_account.example_automation_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  }

  content = data.local_file.example_content.content
}

data "local_file" "example_template" {
  filename = "${path.module}/template/template.json"
}

data "local_file" "example_template_api" {
  filename = "${path.module}/template/azureautomation.json"
}


data "local_file" "example_template_api_log_analaytics" {
  filename = "${path.module}/template/azureloganalytics.json"
}

#API connections
resource "azurerm_resource_group_template_deployment" "example_api_azureautomation" {
  name                = "azureautomation"
  resource_group_name = azurerm_resource_group.example_resource_group.name
  template_content = data.local_file.example_template_api.content
  deployment_mode = "Incremental"
  }

resource "azurerm_resource_group_template_deployment" "example_api_log_analaytics" {
      name                = "azureloganalyticsdatacollector"
      resource_group_name = azurerm_resource_group.example_resource_group.name
      template_content = data.local_file.example_template_api_log_analaytics.content
      deployment_mode = "Incremental"
      }


#Log Analytics workspace to query custom logs sent by logic app
resource "azurerm_log_analytics_workspace" "example_log_analytics" {
  name                = "log-us-workspace"
  location            = azurerm_resource_group.example_resource_group.location
  resource_group_name = azurerm_resource_group.example_resource_group.name

}

#Action group to send email notifications
resource "azurerm_monitor_action_group" "example_action_group" {
  name                = "ag-us-notify-security-action-group"
  resource_group_name = azurerm_resource_group.example_resource_group.name
  short_name          = "NotifySecEng"
  email_receiver {
   name          = "NotifySecEng"
   email_address = var.email_address
 }
}

#Azure Monitor query custom logs sent to Log Analytics
resource "azurerm_monitor_scheduled_query_rules_alert" "example_query" {
  name                = "query-us-non-compliant-alert-rule"
  location            = azurerm_resource_group.example_resource_group.location
  resource_group_name = azurerm_resource_group.example_resource_group.name

  action {
    action_group           = [azurerm_monitor_action_group.example_action_group.id]
    email_subject          = "Azure Policy detected non-compliant resources "

  }
  data_source_id = azurerm_log_analytics_workspace.example_log_analytics.id
  description    = "Notify security when non-compliant resources are triggered on policy scan"
  enabled        = true

  query       = <<-QUERY
AzurePolicy_CL
|where TimeGenerated  > ago(1h)
|parse body_s with * 'SummaryTag' Summary 'ResultTag'*
|parse body_s with * 'ResultTag' Result
|project Summary,Result
|limit 1
  QUERY
  severity    = 3
  frequency   = 60
  time_window = 60
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}

# Logic App  ARM template to be deployed
resource "azurerm_resource_group_template_deployment" "example_logic_app" {
    name = "logic-us-logic-app-alerts"
    resource_group_name = azurerm_resource_group.example_resource_group.name
    template_content = data.local_file.example_template.content
    deployment_mode = "Incremental"

}
