# Set variables
$logAnalyticsWorkspaceId = "Your-LAW-WorkspaceID"
$diagnosticSettingName = "Your-Doagnostic-Setting-Name"

# Conditional login
$context = Get-AzContext
if ($null -eq $context.Account) {
    Connect-AzAccount
}
else {
    Write-Host "Already logged into Azure with account: $($context.Account.Id)"
}

$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {

    Write-Host "Setting subscription context to: $($subscription.Name)"
    Set-AzContext -SubscriptionId $subscription.Id

    $resources = Get-AzResource

    # Array to track what resources have been amended
    $amendedResources = @()

    foreach ($resource in $resources) {
        try {
            $diagnosticSetting = Get-AzDiagnosticSetting -ResourceId $resource.ResourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    
            if ($diagnosticSetting) {
    
                if ($null -ne $diagnosticSetting.EventHubAuthorizationRuleId -and $null -eq $diagnosticSetting.WorkspaceId) {
    
                    Write-Host "Resource found with EH enabled and LAW disabled: $($resource.ResourceId)"
                    Write-Host "Enabling Log Analytics Workspace"
    
                    Set-AzDiagnosticSetting -Name $diagnosticSettingName -ResourceId $resource.ResourceId -WorkspaceId $logAnalyticsWorkspaceId

                    $amendedResources += $resource.ResourceId
    
                }
                elseif ($null -ne $diagnosticSetting.EventHubAuthorizationRuleId -and $null -ne $diagnosticSetting.WorkspaceId) {
    
                    Write-Host "Resource found with both EH and LAW enabled: $($resource.ResourceId)"
                    Write-Host "Removing Event Hub Diagnostic settings"
    
                    Set-AzDiagnosticSetting -Name $diagnosticSettingName -ResourceId $resource.ResourceId -EventHubAuthorizationRuleId $null -EventHubName $null

                    $amendedResources += $resource.ResourceId
    
                }
                elseif ($null -eq $diagnosticSetting.EventHubAuthorizationRuleId -and $null -ne $diagnosticSetting.WorkspaceId) {
    
                    Write-Host "Resource: $($resource.ResourceId) found with LAW enabled and EH disabled - moving on"
    
                }
            }
        } catch {
            Write-Warning "Failed to get diagnostic settings for resource: $($resource.ResourceId)"
        }
    }

    Write-Host ""
    Write-Host ""
    Write-Host ""

    foreach ($amendedResource in $amendedResources) {

        Write-Host "Resource: $($amendedResource) has been amended"

    }

    Write-Host ""
    Write-Host ""
    Write-Host ""

}