Enable-AzureRMAlias -Verbose
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName
Write-Output $automationAccount.AutomationAccountName
$configurations = Get-ChildItem -Path ..\Configurations -Filter *.ps1 -Exclude ConfigurationData.ps1 -File -Recurse

foreach ($configuration in $configurations) {
    Set-Location -Path (Split-Path $configuration.FullName -Parent)
    Write-Verbose -Message "$($configuration.Name)" -Verbose
    $automationAccount | Import-AzureRmAutomationDscConfiguration -SourcePath $configuration.FullName -Published -Force
}