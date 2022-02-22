# Run this manually before 
# Get the Object ID for the DevOps Service Connection

$AzureDevOpsOrg = "https://dev.azure.com/GhostMod" # Insert your dev ops organization example: https://dev.azure.com/ORGNAME
$AzureDevOpsProject = "SecureBotComposer1" # Insert your dev ops project example: SecureBotProject1
$AzureDevOpsServiceConnectionName = "SecureBotAutoInfra2" # Insert name of the service connection: projectSettings > Service Connections > copy paste the service connection name here

$Random = -join ((97..122) | Get-Random -Count 8 | % {[char]$_}) # Ganerating a 8 character string to aid naming uniqueness 
$Location = "westus" # Location of the Resources we will be creating
$MyResourceGroup = "RetailChatBotResources-$Random" # Name of the Resource Group 
$KeyVaultName="rcgbotsecrets-$Random"

$AppRegistrationAD = "retailchatbotreg-$Random" # App Registration Name
$AppRegistrationPassword= "123.456" + -join ((65..90) + (97..122) + (48..57) + 46| Get-Random -Count 25 | % {[char]$_}) #generates random password

az login
az account list --output table
az account set --subscription <insert your sub name or ID>

# Create Resource Group
az group create -l $Location -n $MyResourceGroup

az keyvault create --name $KeyVaultName --resource-group $myResourceGroup --location $Location
$DevOpsConnectionIdentity = $(az devops service-endpoint list --organization $AzureDevOpsOrg --project $AzureDevOpsProject --query "[?name=='$AzureDevOpsServiceConnectionName'].authorization.parameters.serviceprincipalid" --output tsv)
$ObjectID=$(az ad sp show --id $DevOpsConnectionIdentity --query objectId --output tsv)
az keyvault set-policy --name $KeyVaultName --object-id $ObjectID --secret-permissions set get list

az ad app create --display-name $AppRegistrationAD --password $AppRegistrationPassword --available-to-other-tenants
$AppRegistrationID=$(az ad app list --display-name $AppRegistrationAD --query "[].appId" --output tsv)

az keyvault secret set --vault-name $KeyVaultName --name "MicrosoftAppId" --value $AppRegistrationID
az keyvault secret set --vault-name $KeyVaultName --name "MicrosoftAppPassword" --value $AppRegistrationPassword






