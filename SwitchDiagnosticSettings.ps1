# Set variables
$logAnalyticsWorkspaceId = "YOURLAWORKSPACEID"
$diagnosticSettingName = "YOURDIAGNOSTICSETTINGNAME"
$supportedResourceTypes = @(
    "Microsoft.AAD/domainServices",
    "microsoft.aadiam/tenants",
    "Microsoft.AnalysisServices/servers",
    "Microsoft.ApiManagement/service",
    "Microsoft.AppPlatform/Spring",
    "Microsoft.Automation/automationAccounts",
    "Microsoft.Batch/batchAccounts",
    "Microsoft.BatchAI/workspaces",
    "Microsoft.Blockchain/blockchainMembers",
    "Microsoft.Cache/redis",
    "Microsoft.Cdn/profiles/endpoints",
    "Microsoft.ClassicCompute/domainNames/slots/roles",
    "Microsoft.ClassicCompute/virtualMachines",
    "Microsoft.ClassicNetwork/networksecuritygroups",
    "Microsoft.CognitiveServices/accounts",
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Compute/virtualMachineScaleSets",
    "Microsoft.ContainerInstance/containerGroups",
    "Microsoft.ContainerRegistry/registries",
    "Microsoft.ContainerService/managedClusters",
    "Microsoft.CustomerInsights/hubs",
    "Microsoft.DataBoxEdge/dataBoxEdgeDevices",
    "Microsoft.Databricks/workspaces",
    "Microsoft.DataCatalog/datacatalogs",
    "Microsoft.DataFactory/datafactories",
    "Microsoft.DataFactory/factories",
    "Microsoft.DataLakeAnalytics/accounts",
    "Microsoft.DataLakeStore/accounts",
    "Microsoft.DataShare/accounts",
    "Microsoft.DBforMariaDB/servers",
    "Microsoft.DBforMySQL/servers",
    "Microsoft.DBforPostgreSQL/servers",
    "Microsoft.DBforPostgreSQL/serversv2",
    "Microsoft.DesktopVirtualization/applicationGroups",
    "Microsoft.DesktopVirtualization/hostPools",
    "Microsoft.DesktopVirtualization/workspaces",
    "Microsoft.Devices/IotHubs",
    "Microsoft.Devices/provisioningServices",
    "Microsoft.DocumentDB/databaseAccounts",
    "Microsoft.EnterpriseKnowledgeGraph/services",
    "Microsoft.EventGrid/eventSubscriptions",
    "Microsoft.EventGrid/extensionTopics",
    "Microsoft.EventGrid/topics",
    "Microsoft.EventHub/clusters",
    "Microsoft.EventHub/namespaces",
    "Microsoft.HDInsight/clusters",
    "Microsoft.HealthcareApis/services",
    "Microsoft.Insights/AutoscaleSettings",
    "Microsoft.Insights/Components",
    "Microsoft.IoTSpaces/Graph",
    "Microsoft.KeyVault/vaults",
    "Microsoft.Kusto/Clusters",
    "Microsoft.LocationBasedServices/accounts",
    "Microsoft.Logic/integrationAccounts",
    "Microsoft.Logic/integrationServiceEnvironments",
    "Microsoft.Logic/workflows",
    "Microsoft.MachineLearningServices/workspaces",
    "Microsoft.Maps/accounts",
    "Microsoft.Media/mediaservices",
    "Microsoft.NetApp/netAppAccounts/capacityPools",
    "Microsoft.NetApp/netAppAccounts/capacityPools/Volumes",
    "Microsoft.Network/applicationGateways",
    "Microsoft.Network/azurefirewalls",
    "Microsoft.Network/bastionHosts",
    "Microsoft.Network/connections",
    "Microsoft.Network/dnszones",
    "Microsoft.Network/expressRouteCircuits",
    "Microsoft.Network/expressRouteCircuits/peerings",
    "Microsoft.Network/frontdoors",
    "Microsoft.Network/loadBalancers",
    "Microsoft.Network/networkInterfaces",
    "Microsoft.Network/networksecuritygroups",
    "Microsoft.Network/networkWatchers/connectionMonitors",
    "Microsoft.Network/p2sVpnGateways",
    "Microsoft.Network/publicIPAddresses",
    "Microsoft.Network/trafficManagerProfiles",
    "Microsoft.Network/virtualNetworkGateways",
    "Microsoft.Network/virtualNetworks",
    "Microsoft.Network/vpnGateways",
    "Microsoft.NotificationHubs/Namespaces/NotificationHubs",
    "Microsoft.OperationalInsights/workspaces",
    "Microsoft.PowerBIDedicated/capacities",
    "Microsoft.RecoveryServices/Vaults",
    "Microsoft.Relay/namespaces",
    "Microsoft.Search/searchServices",
    "Microsoft.ServiceBus/namespaces",
    "Microsoft.ServiceFabricMesh/applications",
    "Microsoft.SignalRService/SignalR",
    "Microsoft.Sql/managedInstances",
    "Microsoft.Sql/managedInstances/databases",
    "Microsoft.Sql/servers/databases",
    "Microsoft.Sql/servers/elasticPools",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.Storage/storageAccounts/blobServices",
    "Microsoft.Storage/storageAccounts/fileServices",
    "Microsoft.Storage/storageAccounts/queueServices",
    "Microsoft.Storage/storageAccounts/tableServices",
    "microsoft.storagesync/storageSyncServices",
    "Microsoft.StreamAnalytics/streamingjobs",
    "Microsoft.TimeSeriesInsights/environments",
    "Microsoft.TimeSeriesInsights/environments/eventsources",
    "Microsoft.VMwareCloudSimple/virtualMachines",
    "microsoft.web/hostingenvironments",
    "Microsoft.Web/hostingEnvironments/multiRolePools",
    "Microsoft.Web/hostingEnvironments/workerPools",
    "Microsoft.Web/serverfarms",
    "Microsoft.Web/sites",
    "Microsoft.Web/sites/slots"
)

# Initialize the master array to hold results for each subscription
$subscriptionResults = @()

# Conditional login
$context = Get-AzContext
if ($null -eq $context.Account) {
    Connect-AzAccount
}
else {
    Write-Host "Already logged into Azure with account: $($context.Account.Id)"
}

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    Write-Host ""
    Write-Host "Setting subscription context to: $($subscription.Name)"
    Set-AzContext -SubscriptionId $subscription.Id

    # Get all resources in the subscription
    $resources = Get-AzResource

    # Array to track what resources have been missed
    $unAmendedResources = @()

    # Output what subscription is being worked on
    Write-Host ""
    Write-Host "Enabling LAW for supported resources in Subscription: $($subscription.Name)" -ForegroundColor Green
    Write-Host ""

    # Loop through each resource in the subscription
    foreach ($resource in $resources) {
        try {
            # Only enable LAW on supported resource types
            if (($supportedResourceTypes -contains $resource.ResourceType) -and ($resource.ResourceType -ne "Microsoft.Network/azureFirewalls")) {
                Set-AzDiagnosticSetting -ResourceId $resource.ResourceId -WorkspaceId $logAnalyticsWorkspaceId -Enabled $true -Name $diagnosticSettingName -WarningAction SilentlyContinue -ErrorAction Stop >$null 2>&1
                Write-Host "Successfully enabled LAW diagnostic settings for resource: $($resource.ResourceType)/$($resource.ResourceName)"
            }
        } catch {
            Write-Warning "Failed to enable LAW diagnostic settings for resource: $($resource.ResourceType)/$($resource.ResourceName)"
            # Report on resources that did not have LAW enabled that should have
            if ($supportedResourceTypes -contains $resource.ResourceType) {
                $unAmendedResources += "$($resource.ResourceType)/$($resource.ResourceName)"
            }
        }
    }

    # Create an object for this subscription's results
    $subscriptionResult = New-Object PSObject -Property @{
        Name             = $subscription.Name
        FailedResources = $unAmendedResources
    }

    # Add the result for this subscription to the master array
    $subscriptionResults += $subscriptionResult
}

# Output results at the end
Write-Host ""
Write-Host "Complete - Summary of failed resources from LAW enabling process:" -ForegroundColor Green
foreach ($result in $subscriptionResults) {
    if ($result.FailedResources.Count -ne 0) {
        Write-Host "Subscription: $($result.Name)"
        foreach ($resource in $result.FailedResources) {
            Write-Warning "Failed Resource: $resource"
        }
        Write-Host ""
    }
}