$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName

$automationAccount | Get-AzureRmAutomationDscOnboardingMetaconfig -Force

$aaVariables = @("RegistrationKey", "EndpointURL")
$RegistrationKey = (Get-Content ..\DscMetaConfigs\localhost.meta.mof | Select-String "RegistrationKey = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value
$EndpointURL = (Get-Content ..\DscMetaConfigs\localhost.meta.mof | Select-String "ServerURL = `"(?<Key>.+)`";")[1].Matches.Groups[1].Value

foreach ($var in $aaVariables) {
    $exists = $automationAccount | Get-AzureRmAutomationVariable -Name $var -ErrorAction SilentlyContinue
    if ($null -eq $exists) {
        $automationAccount | New-AzureRmAutomationVariable -Name $var -Value (Get-Variable -Name $var -ValueOnly) -Encrypted $false
    }
    else {
        $automationAccount | Set-AzureRmAutomationVariable -Name $var -Value (Get-Variable -Name $var -ValueOnly) -Encrypted $false
    }
}