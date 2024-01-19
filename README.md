# Azure Log Analytics Workspace Enabler Script

## Overview
This PowerShell script is designed to enable Log Analytics Workspace (LAW) diagnostic settings across all resource types in Microsoft Azure subscriptions that are supported by diagnostic settings. It iterates over multiple subscriptions, enabling LAW for each supported resource while specifically excluding Azure Firewalls.

## Prerequisites
- Azure PowerShell Module
- Access to the Azure subscriptions you intend to configure
- Log Analytics Workspace ID

## Usage
1. **Set Variables**: 
   - `$logAnalyticsWorkspaceId`: Set this to your Log Analytics Workspace ID.
   - `$diagnosticSettingName`: Name for the diagnostic setting to be applied.
   - `$supportedResourceTypes`: Array containing all resource types that support diagnostic settings in Azure. Modify as needed.

2. **Login to Azure**: 
   The script checks if you are logged in and prompts for login if necessary.

3. **Run the Script**: 
   Execute the script. It will loop through each subscription accessible to your account, apply diagnostic settings, and generate a report.

## Script Behavior
- The script sets the context to each subscription one by one and fetches all resources.
- It checks each resource to see if it's a type that supports diagnostic settings and is not an Azure Firewall.
- LAW diagnostic settings are applied to each supported resource.
- If the setting application fails, the resource is recorded.
- At the end of execution, the script provides a summary of all resources across subscriptions where LAW could not be enabled.

## Important Notes
- Ensure that the account used has the necessary permissions to modify resources across the subscriptions.
- Review and update the list of supported resource types as per your organizational requirements.
- The script includes error handling to continue execution even if some resources fail to update.

## Disclaimer
This script is provided 'as-is' and should be tested in a non-production environment before use. The author is not responsible for any unintended consequences of using this script in your Azure environment.
