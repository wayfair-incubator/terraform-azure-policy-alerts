Install-Module -Name Az.Accounts -RequiredVersion 2.1.0
Install-Module -Name Az.PolicyInsights
Install-Module -Name Az.Resources -RequiredVersion 3.2.0
Disable-AzContextAutosave –Scope Process
$connectionName = "AzureRunAsConnection"
try
{
    # Connect using "AzureRunAsConnection"
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    "Logging in to Azure..."
   Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    #Check if connection is valid
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#On-demand scan for Azure Policy and filter for policy effect "deny"
$output = Get-AzPolicyState -filter "PolicyDefinitionAction eq 'deny' and ComplianceState eq 'NonCompliant'" 
Write-Output ("SummaryTag")

#Get count of non-compliant resource
if (@($output).Count -gt 0) {


    Write-Output "Total Non-Compliant Resources" $output.Count
    }
else
 {
     Write-Output "All Resources Compliant"
      }
 Write-Output ("ResultTag")

#Get resource name, group and policy name of non-compliant resource
Write-Output ("Results")
foreach ($Result in $output)
{
    $Resource=Get-AzResource -ResourceId $Result.ResourceId | Select Name,ResourceGroupName
    $PolicyName=Get-AzPolicyDefinition -Id $Result.PolicyDefinitionId |Select -ExpandProperty "Properties" | Select -ExpandProperty "displayName"
    #Get summary of the non-compliant resource
    Write-Output ("Resource_Name:" + $Resource.Name)
    Write-Output ("Resource_Group:" + $Resource.ResourceGroupName)
    Write-Output ("Policy_Name:" + $PolicyName)
    Write-Output ""

}
