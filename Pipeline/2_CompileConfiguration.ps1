Enable-AzureRMAlias
$ResourceGroupName = $env:ResourceGroupName
$automationAccountName = $env:AutomationAccountName

Set-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY\Pipeline

$automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $automationAccountName

$configurations = Get-ChildItem -Path ..\Configurations -Filter *.ps1 -Exclude ConfigurationData.ps1 -File -Recurse

foreach ($configuration in $configurations) {
    Set-Location -Path (Split-Path $configuration.FullName -Parent)
    Write-Verbose -Message "Compiling $($configuration.BaseName)" -Verbose
    $job = $automationAccount | Start-AzureRMAutomationDscCompilationJob -ConfigurationName $configuration.BaseName -Verbose
    while ($job.Status -ne "Completed") {
        Write-Verbose -Message "$($job.Status.ToUpper()) :Waiting for compilation job for configuration $($configuration.BaseName) to complete" -Verbose
        Start-Sleep -Seconds 10
        $job = $automationAccount | Get-AzureRmAutomationDscCompilationJob -Id $job.Id
    }
}