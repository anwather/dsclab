# PowerShell DSC pipeline #

This repository contains code to use Azure Automation State Configuration (DSC) in an on-premises environment. It uses a YAML Azure Pipeline to deploy the configurations to an automation account and a hybrid runbook worker on-premises to register nodes to the service.

## Pre-requisites ##

1) On-premises domain environment
2) Azure Automation Account
3) Hybrid Runbook Worker registered to the automation account - used to register the other nodes with Azure Automation State Configuration
4) Azure DevOps project to store the configurations and code
5) Service Connection registered in the Azure DevOps project to connect to Azure. 
6) Credential in the automation account that has access to machines for pushing LCM configuration to (uses PowerShell remoting so local administrator required by default) e.g.
```powershell
$automationAccount = Get-AzureRMAutomationAccount -Name myaccountname -ResourceGroupName mygroupname
$credential = Get-Credential -Message "Enter domain account for PowerShell remoting"
$automationAccount | New-AzureRMAutomationCredential -Name 'DSC Account' -Value $credential 
```

## Setup ##

- Clone the repository and add it to the Azure DevOps project.
- Create a service connection to connect to Azure.
- Update ```azure-pipelines.yml``` to use the new connection.

## Components ##

- Configurations folder - used to store the DSC configurations in
    - This contains a simple sample configuration - more complex examples would require configuration data to be added to the compilation process and modules to be imported to the automation account.
- Nodes folder - stores the information about nodes to be registered
    - Contains a ```nodes.csv``` file which contains a series or node names to be registered and their corresponding compile configuration.
- Runbooks folder - store runbooks to be uploaded to the automation account
    - Contains a single runbook which runs on the Hybrid Runbook Worker and sends LCM configuration to nodes contained in the nodes CSV file
- Pipeline folder - contains the scripts for the Azure Pipeline

## Explanation of process ##

1) Modify the ```azure-pipelines.yml``` file variable to your automation account name and resource group. You will also have to create a service connection to Azure - this is then used by the tasks to login to ARM. 
1) Make changes to the configurations / add nodes to the nodes.csv file etc..... Commit all changes and push to trigger the deployment process in Azure Pipelines
2) Once triggered the pipeline runs a series of Azure PowerShell tasks which complete the following:-
    1) Upload all configurations to the automation account
    2) Compile configurations in the pull server
    3) Upload runbooks to the automation account
    4) Register DSC nodes which aren't present or if a registered nodes configuration has change it will be re-registered. This is done by starting the runbook which runs on the hybrid runbook worker. It generates a new LCM configuration and uses the ```Set-DSCLocalConfigurationManager``` cmdlet to push the new metaconfig.

