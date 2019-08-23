Enable-AzureRMAlias
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

Set-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY\Pipeline

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName

$nodes = Import-CSV -Path ..\Nodes\nodes.csv

Write-Verbose -Message "Generating metaconfig from automation account" -Verbose
$automationAccount | Get-AzureRmAutomationDscOnboardingMetaconfig -Force

$mofFile = Get-ChildItem -Path D:\a\_tasks -Filter localhost.meta.mof -Recurse -Force

$aaVariables = @("RegistrationKey", "EndpointURL")
$RegistrationKey = (Get-Content $mofFile.FullName | Select-String "RegistrationKey = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value
$EndpointURL = (Get-Content $mofFile.FullName | Select-String "ServerURL = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value


foreach ($node in $nodes) {
    $exists = $automationAccount | Get-AzureRmAutomationDscNode -Name $node.NodeName
    if ($null -eq $exists) {
        $params = @{
            EndpointURL     = $EndpointURL
            RegistrationKey = $RegistrationKey
            NodeName        = $node.NodeName
            Configuration   = $node.Configuration
        }
        Write-Verbose -Message "Starting runbook to register node $($node.NodeName)" -Verbose
        $automationAccount | Start-AzureRmAutomationRunbook -Name Register-LocalNode -Parameters $params -RunOn Master
    }
    else {
        Write-Verbose -Message "Node $($node.NodeName) already exists in Azure Automation" -Verbose
        if ($exists.NodeConfigurationName -ne $node.Configuration) {
            Write-Verbose -Message "Configuration is different on node $($node.NodeName) - registering again" -Verbose
            $params = @{
                EndpointURL     = $EndpointURL
                RegistrationKey = $RegistrationKey
                NodeName        = $node.NodeName
                Configuration   = $node.Configuration
            }
            $automationAccount | Start-AzureRmAutomationRunbook -Name Register-LocalNode -Parameters $params -RunOn Master
        }
    }
}
