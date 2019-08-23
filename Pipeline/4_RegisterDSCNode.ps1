Enable-AzureRMAlias
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

Set-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY\Pipeline

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName

$nodes = Import-CSV -Path ..\Nodes\nodes.csv

$automationAccount | Get-AzureRmAutomationDscOnboardingMetaconfig -Force

$aaVariables = @("RegistrationKey", "EndpointURL")
$RegistrationKey = (Get-Content .\DscMetaConfigs\localhost.meta.mof | Select-String "RegistrationKey = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value
$EndpointURL = (Get-Content .\DscMetaConfigs\localhost.meta.mof | Select-String "ServerURL = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value


foreach ($node in $nodes) {
    $exists = $automationAccount | Get-AzureRmAutomationDscNode -Name $node.NodeName
    if ($null -eq $exists) {
        $params = @{
            EndpointURL     = $EndpointURL
            RegistrationKey = $RegistrationKey
            NodeName        = $node.NodeName
            Configuration   = $node.Configuration
        }
        $automationAccount | Start-AzureRmAutomationRunbook -Name Register-LocalNode -Parameters $params -RunOn Master
    }
}
