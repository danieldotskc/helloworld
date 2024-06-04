<#
    .SYNOPSIS
    Creates an ExecuteAzCommand { azure resource group with the resources required for the HPSP integration.
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("poc","t01","t02")]
    [string]$Environment,

    [ValidateNotNullOrEmpty()]
    [string]$ResourceLocation = "australiacentral",

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Leaf})]
    [string]$ServiceBusTemplateFilepath = "$PSScriptRoot\..\templates\service-bus.json",

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Leaf})]
    [string]$AppServicePlanTemplateFilepath = "$PSScriptRoot\..\templates\app-service-plan.json",

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Leaf})]
    [string]$WebAppTemplateFilepath = "$PSScriptRoot\..\templates\web-app.json",

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Leaf})]
    [string]$FunctionAppTemplateFilepath = "$PSScriptRoot\..\templates\azure-function-app.json",

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Leaf})]
    [string]$RelayTemplateFilepath = "$PSScriptRoot\..\templates\relay.json",

    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = "auc-hbrp-{env}-app-rg01",

    [ValidateNotNullOrEmpty()]
    [string]$ApplicationInsightsName = "auc-hbrp-{env}-func-ai01",

    [ValidateNotNullOrEmpty()]
    [string]$LogAnalyticsWorkspaceName = "auc-hbrp-{env}-law01",

    [ValidateNotNullOrEmpty()]
    [string]$StorageAccountName = "auchpsp{env}datasa01",

    [ValidateNotNullOrEmpty()]
    [string]$ServiceBusName = "auc-hbrp-{env}-app-sb01",

    [ValidateNotNullOrEmpty()]
    [string]$AppServicePlanName = "auc-hbrp-{env}-asp01",

    [ValidateNotNullOrEmpty()]
    [string]$WebAppName = "auc-hbrp-{env}-wa01",

    [ValidateNotNullOrEmpty()]
    [string]$FunctionAppName = "auc-hbrp-{env}-fa01",

    [ValidateNotNullOrEmpty()]
    [string]$UserAssignedManagedIdentityName = "auc-hbrp-{env}-uami-fa01",

    [ValidateNotNullOrEmpty()]
    [string]$ServiceBusPartyDataQueueName = "party-data",

    [ValidateNotNullOrEmpty()]
    [string]$ServiceBusReferenceDataQueueName = "reference-data",

    [ValidateNotNullOrEmpty()]
    [string]$ServiceBusSubmissionDataQueueName = "submission-data",

    [ValidateNotNullOrEmpty()]
    [string]$ServiceBusSMDataQueueName = "stakeholdermanagement-data",

    [ValidateNotNullOrEmpty()]
    [string]$RelayName = "auc-hbrp-{env}-relay-fa01",

    [ValidateNotNullOrEmpty()]
    [string]$RelayHybridConnectionName = "stakeholdermanagementconnection",

    [ValidateNotNullOrEmpty()]
    [string]$StorageTableHPSPEventTableName = "hpspevent",

    [int]$StorageTableLookupIntervalSeconds = 30,

    [int]$ServiceBusDeliveryDelayMinutes = 60
)

$envPlaceholder = "{env}"
$target_env = $Environment

function ExecuteAzCommand {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [scriptblock]$Command
    )

    # Write the az commands to the DevOps log with appropriate highlighting using "##[Command]"
    Write-Host "##[Command]$($ExecutionContext.InvokeCommand.ExpandString($Command))"
    $result = Invoke-Command $Command -NoNewScope

    if (0 -ne $LASTEXITCODE) {
        throw "Command failed, please check logs."
    }

    return $result
}

function ReplaceEnv {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ResourceName
    )

    return "$($ResourceName)".Replace($envPlaceholder, $($target_env))
}

$location = $ResourceLocation
$servicebus_template_file = Resolve-Path $ServiceBusTemplateFilepath
$appserviceplan_template_file = Resolve-Path $AppServicePlanTemplateFilepath
$webapp_template_file = Resolve-Path $WebAppTemplateFilepath
$functionapp_template_file = Resolve-Path $FunctionAppTemplateFilepath
$relay_template_file = Resolve-Path $RelayTemplateFilepath
$rg_name = ReplaceEnv $ResourceGroupName
$application_insights_name = ReplaceEnv $ApplicationInsightsName
$log_analytics_workspaces_name = ReplaceEnv $LogAnalyticsWorkspaceName
$storageaccount_name = ReplaceEnv $StorageAccountName
$servicebus_name = ReplaceEnv $ServiceBusName
$appserviceplan_name = ReplaceEnv $AppServicePlanName
$webapp_name = ReplaceEnv $WebAppName
$functionapp_name = ReplaceEnv $FunctionAppName
$user_assigned_managed_id_name = ReplaceEnv $UserAssignedManagedIdentityName
$relay_namespace_name = ReplaceEnv $RelayName
$relay_hybrid_connection_name = $RelayHybridConnectionName
$servicebus_partydata_queue_name = $ServiceBusPartyDataQueueName
$servicebus_referencedata_queue_name = $ServiceBusReferenceDataQueueName
$servicebus_submissiondata_queue_name = $ServiceBusSubmissionDataQueueName
$servicebus_stakeholdermangementdata_queue_name = $ServiceBusSMDataQueueName
$storagetable_hpspevent_tablename = $StorageTableHPSPEventTableName
$storagetable_lookup_internval_seconds = $StorageTableLookupIntervalSeconds
$servicebus_delivery_delay_minutes = $ServiceBusDeliveryDelayMinutes

$account = ExecuteAzCommand { az account show } | ConvertFrom-Json
$target_tenant_id = $account.tenantId
$subscription_id = $account.id

# resource group
ExecuteAzCommand { az group create --name $rg_name --location $location }

# log analytics workspace & application insights
ExecuteAzCommand { az config set extension.use_dynamic_install=no_without_prompt }

# log-analytics workspace
$workspaces = ExecuteAzCommand { az monitor log-analytics workspace list --resource-group $rg_name } | ConvertFrom-Json
if ($workspaces.name -notcontains $log_analytics_workspaces_name) {
    Write-Output "'$($log_analytics_workspaces_name)' Log-Analytics-Workspace does not exist, and script proceeds the Log-Analytics-Workspace creation step."
    ExecuteAzCommand { az monitor log-analytics workspace create --name $log_analytics_workspaces_name --resource-group $rg_name --location $location }
}
else {
    Write-Output "'$($log_analytics_workspaces_name)' Log-Analytics-Workspace already exists, therefore script skips the Log-Analytics-Workspace creation step."
}

# application insights
$appinsights = ExecuteAzCommand { az monitor app-insights component show -g $rg_name } | ConvertFrom-Json
if ($appinsights.name -notcontains $application_insights_name) {
    Write-Output "'$($application_insights_name)' does not exist, and script proceeds the Application-Insights creation step."
    ExecuteAzCommand { az monitor app-insights component create --app $application_insights_name --location $location --resource-group $rg_name --workspace $log_analytics_workspaces_name }
}
else {
    Write-Output "'$($application_insights_name)' Application-Insights already exists, therefore script skips the Application-Insights creation step."
}

# storage account
$storageaccounts = ExecuteAzCommand { az storage account list --resource-group $rg_name } | ConvertFrom-Json
if ($storageaccounts.name -notcontains $storageaccount_name) {
    Write-Output "'$($storageaccount_name)' Storage-Account does not exist, and script proceeds the Storage-Account creation step."
    ExecuteAzCommand { az storage account create --name $storageaccount_name --resource-group $rg_name --access-tier Hot --location $location --min-tls-version TLS1_2 --allow-blob-public-access false --allow-cross-tenant-replication false }

    Write-Output "Start sleep for 30 seconds"
    Start-Sleep -Seconds 30
    Write-Output "Wake up from sleep for updating data protection configuration"
    ExecuteAzCommand { az storage account blob-service-properties update --enable-container-delete-retention true --container-delete-retention-days 7 --account-name $storageaccount_name --resource-group $rg_name }
    ExecuteAzCommand { az storage blob service-properties update --account-name $storageaccount_name --delete-retention true --delete-retention-period 7 }
    ExecuteAzCommand { az storage table create --name $storagetable_hpspevent_tablename --account-name $storageaccount_name }
}
else {
    Write-Output "'$($storageaccount_name)' Storage-Account already exists, therefore script skips the Storage-Account creation step."
}

# # service bus
# ExecuteAzCommand { az deployment group create `
#     --name servicebustemplate `
#     --resource-group $rg_name `
#     --template-file $servicebus_template_file `
#     --parameters `
#     paramLocation=$location `
#     paramServiceBusNamespace=$servicebus_name `
#     paramPartyDataQueue=$servicebus_partydata_queue_name `
#     paramReferenceDataQueue=$servicebus_referencedata_queue_name `
#     paramSubmissionDataQueue=$servicebus_submissiondata_queue_name `
#     paramStakeholderManagementDataQueue=$servicebus_stakeholdermangementdata_queue_name }

# # managed identity
# $identities = ExecuteAzCommand { az identity list --resource-group $rg_name } | ConvertFrom-Json
# if ($identities.name -notcontains $user_assigned_managed_id_name) {
#     Write-Output "'$($user_assigned_managed_id_name)' Managed-Identity does not exist, and script proceeds the Managed-Identity creation step."
#     ExecuteAzCommand { az identity create --name $user_assigned_managed_id_name --resource-group $rg_name --location $location }
# }
# else {
#     Write-Output "'$($user_assigned_managed_id_name)' Managed-Identity already exists, therefore script skips the Managed-Identity creation step."
# }

# # relay
# $relays = ExecuteAzCommand { az relay namespace list --resource-group $rg_name } | ConvertFrom-Json
# if ($relays.name -notcontains $relay_namespace_name) {
#     Write-Output "'$($relay_namespace_name)' Relay does not exist, and script proceeds the Relay creation step."
#     ExecuteAzCommand { az deployment group create --name relaytemplate --resource-group $rg_name --template-file $relay_template_file --parameters paramLocation=$location paramRelayName=$relay_namespace_name paramHybridConnectionName=$relay_hybrid_connection_name }
# }
# else {
#     Write-Output "'$($relay_namespace_name)' Relay already exists, therefore script skips the Relay creation step."
# }

# app service plan
$serviceplans = ExecuteAzCommand { az appservice plan list --resource-group $rg_name } | ConvertFrom-Json
if ($serviceplans.name -notcontains $appserviceplan_name) {
    Write-Output "'$($appserviceplan_name)' Service-Plan does not exist, and script proceeds the Service-Plan creation step."
    ExecuteAzCommand { az deployment group create --name appplantemplate --resource-group $rg_name --template-file $appserviceplan_template_file --parameters paramLocation=$location paramAppServicePlanName=$appserviceplan_name }
}
else {
    Write-Output "'$($appserviceplan_name)' Service-Plan already exists, therefore script skips the Service-Plan creation step."
}

# web app
$webapps = ExecuteAzCommand { az webapp list --resource-group $rg_name } | ConvertFrom-Json
if ($webapps.name -notcontains $webapp_name) {
    Write-Output "'$($webapp_name)' Web-app does not exist, and script proceeds the Web-app creation step."
    ExecuteAzCommand { az deployment group create --name appplantemplate --resource-group $rg_name --template-file $webapp_template_file --parameters paramName=$webapp_name paramSubscriptionId=$subscription_id paramResourceGroupName=$rg_name paramAppServicePlanName=$appserviceplan_name }
}
else {
    Write-Output "'$($appserviceplan_name)' Web-app already exists, therefore script skips the Web-app creation step."
}

# # function app
# $functionapps = ExecuteAzCommand { az functionapp list --resource-group $rg_name } | ConvertFrom-Json
# if ($functionapps.name -notcontains $functionapp_name) {
#     Write-Output "'$($functionapp_name)' Function-App does not exist, and script proceeds the Function-App creation step."
#     ExecuteAzCommand { az deployment group create --name funcapptemplate --resource-group $rg_name --template-file $functionapp_template_file --parameters paramSubscriptionId=$subscription_id paramResourceGroup=$rg_name paramFunctionAppName=$functionapp_name paramAppInsightsName=$application_insights_name paramLocation=$location paramAppServicePlanName=$appserviceplan_name paramUserAssignManagedIdentityName=$user_assigned_managed_id_name }
# }
# else {
#     Write-Output "'$($functionapp_name)' Function-App already exists, therefore script skips the Function-App creation step."
# }

# # add function app configuration settings
# $app_insight_connection_string = ExecuteAzCommand { az resource show -g $rg_name -n $application_insights_name --resource-type "microsoft.insights/components" --query properties.ConnectionString }
# Write-Output "app insight connection-string: $($app_insight_connection_string)"

# $storage_account_connection_string = ExecuteAzCommand { az storage account show-connection-string --name $storageaccount_name --resource-group $rg_name --subscription $subscription_id } | ConvertFrom-Json
# $storage_account_connection_string = $storage_account_connection_string.connectionString
# Write-Output "storage account connection-string: $($storage_account_connection_string)"

# $servicebus_fullyqualifiednamespace = "$($servicebus_name).servicebus.windows.net"
# $storageaccount_credential = "managedidentity"
# $storageaccount_blob_service_uri = "https://$($storageaccount_name).blob.core.windows.net"
# $storageaccount_queue_service_uri = "https://$($storageaccount_name).queue.core.windows.net"
# $storageaccount_table_service_uri = "https://$($storageaccount_name).table.core.windows.net"

# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings TenantId=$target_tenant_id }

# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings APPLICATIONINSIGHTS_CONNECTION_STRING=$app_insight_connection_string }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AzureWebJobsStorage__credential=$storageaccount_credential }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AzureWebJobsStorage__blobServiceUri=$storageaccount_blob_service_uri }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AzureWebJobsStorage__queueServiceUri=$storageaccount_queue_service_uri }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AzureWebJobsStorage__tableServiceUri=$storageaccount_table_service_uri }

# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusConnection__fullyQualifiedNamespace=$servicebus_fullyqualifiednamespace }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusPartyDataQueueName=$servicebus_partydata_queue_name }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusReferenceDataQueueName=$servicebus_referencedata_queue_name }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusSubmissionDataQueueName=$servicebus_submissiondata_queue_name }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusStakeholderManagementDataQueueName=$servicebus_stakeholdermangementdata_queue_name }

# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings HPSPCrmUrl=$hpsp_crm_url }

# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings StorageTableHPSPEventTableName=$storagetable_hpspevent_tablename }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings StorageTableLookupIntervalSeconds=$storagetable_lookup_internval_seconds }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings ServiceBusDeliveryDelayMinutes=$servicebus_delivery_delay_minutes }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AzureRelayName=$relay_namespace_name }
# ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings RelayHybridConnectionName=$relay_hybrid_connection_name }

# # Function App User-Assigned Managed Identity client ID appsetting
# $user_assigned_managed_ids = ExecuteAzCommand { az identity list --resource-group $rg_name --subscription $subscription_id } | ConvertFrom-Json 

# if ($user_assigned_managed_ids.name -contains $user_assigned_managed_id_name) {
#     $user_assigned_managed_id = ExecuteAzCommand { az identity show --name $user_assigned_managed_id_name --resource-group $rg_name --subscription $subscription_id } | ConvertFrom-Json
#     $user_assigned_managed_id_clientid = $user_assigned_managed_id.clientId
#     Write-Output "Function App User-Assigned Managed Identity client ID: $($user_assigned_managed_id_clientid)"
#     ExecuteAzCommand { az functionapp config appsettings set --name $functionapp_name --resource-group $rg_name --settings AZURE_CLIENT_ID=$user_assigned_managed_id_clientid }
# }
# else {
#     Write-Output "Function App User-Assigned Managed Identity: $($user_assigned_managed_id_name) does not exist, so skipped setting the Function App appsetting."
# }