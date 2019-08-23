Enable-AzureRMAlias
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

Set-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY\Pipeline

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName
$configurations = Get-ChildItem -Path ..\Configurations -Filter *.ps1 -Exclude ConfigurationData.ps1 -File -Recurse

foreach ($configuration in $configurations) {
    Set-Location -Path (Split-Path $configuration.FullName -Parent)
    Write-Verbose -Message "Uploading $($configuration.Name) to automation account" -Verbose
    $automationAccount | Import-AzureRmAutomationDscConfiguration -SourcePath $configuration.FullName -Published -Force
}