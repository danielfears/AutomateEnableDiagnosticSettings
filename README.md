# Azure Resource Diagnostic Settings Automation Script

## Introduction
This PowerShell script is designed to automate the process of configuring diagnostic settings for Azure resources. It ensures that all Azure resources within your subscriptions are correctly configured with Log Analytics Workspace (LAW) and Event Hub (EH) diagnostic settings.

## Prerequisites
- Azure PowerShell module: The script requires the Azure PowerShell module to be installed and available on the system where the script is run.
- Azure Account: A user account with sufficient permissions to modify diagnostic settings across the Azure resources.
- Log Analytics Workspace ID and Diagnostic Setting Name: These values need to be provided within the script.

## Configuration
Before running the script, configure the following variables within the script:
- `$logAnalyticsWorkspaceId`: Your Log Analytics Workspace ID.
- `$diagnosticSettingName`: Your preferred name for the diagnostic settings.

## Usage
To use this script, follow these steps:
1. Open your PowerShell terminal.
2. Ensure you are logged into your Azure account. If not, the script will prompt for login.
3. Run the script.

## How It Works
1. **Conditional Login**: Checks if you are logged into Azure and prompts for login if not.
2. **Subscription Handling**: Iterates through all Azure subscriptions accessible to your account.
3. **Resource Processing**: For each subscription, it retrieves all resources and processes each one to check and set the diagnostic settings as follows:
   - If a resource has Event Hub (EH) enabled and LAW disabled, it enables LAW.
   - If a resource has both EH and LAW enabled, it removes the Event Hub Diagnostic settings.
   - If a resource has LAW enabled and EH disabled, it leaves the resource as-is.
4. **Error Handling**: In case of any failures in retrieving the diagnostic settings for a resource, it outputs a warning.
5. **Tracking Changes**: All amended resources are tracked and reported at the end of processing each subscription.

## Notes
- The script outputs the status and actions taken for each resource in the console.
- Ensure you have the necessary permissions before running the script to avoid access-related errors.

## Disclaimer
This script is provided 'as is' and should be tested in a non-production environment before use. The author is not responsible for any unintended effects of this script.

## Contribution
Feedback and contributions to this script are welcome. Please submit your suggestions or improvements as pull requests or issues in the repository.
