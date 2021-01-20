Version history
======

### Version 1.1

## Terraform resources

* In this version the following resources are deployed under `rg-us-policy-resource-group`

| Resource Type | Resource Name |   
| ------------- |:-------------:|
|   Automation account   | aa-us-policy-automation-account |
| Automation Connection     | AzureRunAsConnection      |
| Automation Certificate| AzureRunAsCertificate|
| Powershell Runbook |rb-us-powershell-runbook      |  
| Logic app ARM template | logic-us-logic-app-alerts|
|Log Analytics workspace |  log-us-workspace |
| Action Group | ag-us-notify-security-action-group |
| Query Rules Alert | query-us-non-compliant-alert-rule |
|API Connections| azureautomation |
|Log Analytics Data Collector | azureloganalyticsdatacollector-1 |

* Azure modules are also downloaded to assist the runbook
* [Runbook](https://github.csnzoo.com/rk896g/azurepolicyalerts/tree/master/alerts-scripts/runbook) is referred to create scheduled job to detect non-compliant resources
* [Templates](https://github.csnzoo.com/rk896g/azurepolicyalerts/tree/master/alerts-scripts/template) are referred to create the workflow for logic app
