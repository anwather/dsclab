Enable-AzureRMAlias
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

Set-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY\Pipeline

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName

$runbooks = Get-ChildItem -Path ..\Runbooks -Filter *.ps1 -File

foreach ($runbook in $runbooks) {
    Write-Verbose -Message "Uploading $($runbook.BaseName) to automation account" -Verbose
    $automationAccount | Import-AzureRmAutomationRunbook -Name $runbook.BaseName -Path $runbook.FullName -Type PowerShell -Published -Force -LogVerbose $true
}
