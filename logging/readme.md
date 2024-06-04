az login

az account set --subscription "9c0251c2-ed26-453e-bd57-3695ca3d33d0"

deploy.ps1 -Environment t01


### Telemetry

https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core?tabs=netcorenew#enable-application-insights-server-side-telemetry-visual-studio

### Logging

https://learn.microsoft.com/en-us/azure/azure-monitor/app/ilogger?tabs=dotnet6

**Need to add Application Insight's Connection string in the 'Environment variables' Connection strings' of Azure Web App**

Name: *APPLICATIONINSIGHTS_CONNECTION_STRING*

Value: *InstrumentationKey=a7395733-bcb3-4968-a12d-32150a95e34e;IngestionEndpoint=https://australiacentral-0.in.applicationinsights.azure.com/;LiveEndpoint=https://australiacentral.livediagnostics.monitor.azure.com/;ApplicationId=bc799c5e-a3cb-4dc1-bbf5-d5b8532ea0bd* (sample)
