[CmdletBinding()]
param (
    $MyResourceGroup,
    $KeyVaultName
)
$Random = -join ((97..122) | Get-Random -Count 6 | % {[char]$_}) # Ganerating a 6 character string to aid naming uniqueness 
$Location = "westus" # Location of the Resources we will be creating
$AppServicePlanName = "retailchatbot-$Random" # Name of the App Service Plan
$BotPortalFrontEnd = "retailbotportalfrontend-$Random" # Front End Web App Name
$BotFrameworkBackEnd = "retailbotframeworkbackend-$Random" # Back End Web App Name
$VnetName = "retailbotVnet$Random" # Name of the Vnet
$FrontEndSubnetName = "FrontEndSubnet-$Random" # Name of Front End Subnet
$BackEndSubnetName = "BackEndSubnet-$Random" # Name of Back End Subnet
$VnetIntegrationSubnet1 = "VnetIntegrationSubnet1-$Random" # Name of Vnet Integration Subnet1
$VnetIntegrationSubnet2 = "VnetIntegrationSubnet2-$Random" # Name of Vnet Integration Subnet2
$PrivateEndpointSubnet1 = "PrivateEndpointSubnet-$Random" # Name of Private Endpoint Subnet
$PrivateEndpointConnectionName = "privateendpointconn-$Random" # Name of Front End Subnet
$BotName="azurercgbot-$Random" # Azure Bot Name
#$AppRegistrationAD = "retailchatbotreg-$Random" # App Registration Name
#$AppRegistrationPassword= "123.456" + -join ((65..90) + (97..122) + (48..57) + 46| Get-Random -Count 25 | % {[char]$_}) #generates random password

$StorageAccountName="botapicode$Random" # Storage account name (please note that it needs to be all lowercase)
$FunctionName="botapi-$Random" # Name for our function app
$PrivateEndpointName="pricateendpoint-$Random" # Name for private endpoints
$ServiceBusNamespace="botsbns-$Random" # ServiceBus namespace name
$ServiceBusQueName="botsbque" # Service Bus Que Name
$accountName="cosmos-$Random" #needs to be lower case
$databaseName="botstate-db"
$containerName="botstate-container"

$LuisAuthoringName="mybot-luis-auth-$Random" # Luis Authoring Name
$LuisPredictionName="mybot-luis-pred-$Random" # Luis Prediction Name

$AppRegistrationPassword = $(az keyvault secret show --name MicrosoftAppPassword --vault-name $KeyVaultName --query "value" --output tsv)
$AppRegistrationID = $(az keyvault secret show --name MicrosoftAppId --vault-name $KeyVaultName --query "value" --output tsv)

# Network Resources

az network vnet create --name $VnetName --resource-group $MyResourceGroup --location $Location --address-prefix 10.1.1.0/24 --subnet-name $FrontEndSubnetName --subnet-prefix 10.1.1.0/26
az network vnet subnet create --address-prefix 10.1.1.64/26 --name $BackEndSubnetName --resource-group $MyResourceGroup --vnet-name $VnetName
az network vnet subnet create --address-prefix 10.1.1.128/27 --name $PrivateEndpointSubnet1 --resource-group $MyResourceGroup --vnet-name $VnetName
az network vnet subnet create --address-prefix 10.1.1.192/27 --name $VnetIntegrationSubnet1 --resource-group $MyResourceGroup --vnet-name $VnetName
az network vnet subnet create --address-prefix 10.1.1.224/27 --name $VnetIntegrationSubnet2 --resource-group $MyResourceGroup --vnet-name $VnetName

# App Service Resources

az appservice plan create --name $AppServicePlanName --resource-group $MyResourceGroup --sku P1v2 --is-linux
az webapp create -g $MyResourceGroup -p $AppServicePlanName -n $BotPortalFrontEnd -r DOTNETCORE:3.1
az webapp create -g $MyResourceGroup -p $AppServicePlanName -n $BotFrameworkBackEnd -r DOTNETCORE:3.1
az webapp config set -g $MyResourceGroup -n $BotFrameworkBackEnd --web-sockets-enabled true
az webapp vnet-integration add --name $BotFrameworkBackEnd --resource-group $MyResourceGroup --subnet $VnetIntegrationSubnet1 --vnet $VnetName
az webapp config set --resource-group $MyResourceGroup --name $BotFrameworkBackEnd --vnet-route-all-enabled true
az webapp identity assign --name $BotFrameworkBackEnd --resource-group $MyResourceGroup
$AppIdentity=$(az webapp identity show --name $BotFrameworkBackEnd --resource-group $MyResourceGroup --query "principalId" --output tsv)
az webapp identity assign --name $BotPortalFrontEnd --resource-group $MyResourceGroup
$AppIdentityFe=$(az webapp identity show --name $BotPortalFrontEnd --resource-group $MyResourceGroup --query "principalId" --output tsv)

# Key Vault

#az keyvault create --name $KeyVaultName --resource-group $myResourceGroup --location $Location # MANUAL FOR NOW
az keyvault set-policy --name $KeyVaultName --object-id $AppIdentity --secret-permissions get list
az keyvault set-policy --name $KeyVaultName --object-id $AppIdentityFE --secret-permissions get list
$KeyVaultURI=(az keyvault show --name $KeyVaultName --query "properties.vaultUri" --output tsv)
az webapp config appsettings set -n $BotFrameworkBackEnd -g $MyResourceGroup --settings KnowYourCustomerBotKeyVaultUrl=$KeyVaultURI
az webapp config appsettings set -n $BotPortalFrontEnd -g $MyResourceGroup --settings KnowYourCustomerBotKeyVaultUrl=$KeyVaultURI

# Service Bus Namespace and Que Not in current bot implementation

# az servicebus namespace create --resource-group $MyResourceGroup --name $ServiceBusNamespace --location $Location
# az servicebus queue create --resource-group $MyResourceGroup --namespace-name $ServiceBusNamespace --name $ServiceBusQueName
# $ServiceBusConnectionString=$(az servicebus namespace authorization-rule keys list --resource-group $MyResourceGroup --namespace-name $ServiceBusNamespace --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
# az keyvault secret set --vault-name $KeyVaultName --name "AzureServiceBusConnectionString" --value $ServiceBusConnectionString

# App Registration Run Manually for now

#az ad app create --display-name $AppRegistrationAD --password $AppRegistrationPassword --available-to-other-tenants
#$AppRegistrationID=$(az ad app list --display-name $AppRegistrationAD --query "[].appId" --output tsv)

# CosmosDB

az cosmosdb create -n $accountName -g $MyResourceGroup
az cosmosdb sql database create -a $accountName -g $MyResourceGroup -n $databaseName
az cosmosdb sql container create -a $accountName -g $MyResourceGroup -d $databaseName -n $containerName -p "/id" --throughput 400
$CosmosPrimMasterKey=$(az cosmosdb keys list --name $accountName --resource-group $MyResourceGroup --query "primaryMasterKey" --output tsv)
$CosmosEndpoint=$(az cosmosdb show --name $accountName --resource-group $MyResourceGroup --query "documentEndpoint" --output tsv)

# Azure Bot

az deployment group create --resource-group $MyResourceGroup --template-file "infrastructure/azurebot.json" --parameters appId=$AppRegistrationID appSecret=$AppRegistrationPassword botId=$BotName newWebAppName=$BotFrameworkBackEnd existingAppServicePlan=$AppServicePlanName appServicePlanLocation=$Location --name $BotName
$WebBotWebChannelKey=(az bot webchat show --name $BotName --resource-group $MyResourceGroup --with-secrets  true --query "setting.sites[].key" --output tsv)


# Storage Account

az storage account create --name $StorageAccountName --sku Standard_LRS --resource-group $MyResourceGroup --location $Location
az functionapp create --storage-account $StorageAccountName --runtime python --plan $AppServicePlanName --runtime-version 3.8 --functions-version 3 --name    $FunctionName --os-type Linux --resource-group $MyResourceGroup
az functionapp config appsettings set --name $FunctionName --resource-group $MyResourceGroup --settings "AzureServiceBusConnectionString=$ServiceBusConnectionString"
$BotWebAppURL=$(az webapp show --name $BotFrameworkBackEnd --resource-group $MyResourceGroup --query "hostNames" --output tsv)
az functionapp config appsettings set --name $FunctionName --resource-group $MyResourceGroup --settings "BotWebAppURL=$BotWebAppURL"
az functionapp identity assign -g $MyResourceGroup -n $FunctionName
$AppIdentityFunction=$(az functionapp identity show --name $FunctionName --resource-group $MyResourceGroup --query "principalId" --output tsv)
az keyvault set-policy --name $KeyVaultName --object-id $AppIdentityFunction --secret-permissions get list
$ServiceBusConnStrKeyURL=(az keyvault secret show --name "AzureServiceBusConnectionString" --vault-name $KeyVaultName --query "id" --output tsv)
az functionapp config appsettings set --name $FunctionName --resource-group $MyResourceGroup --settings "AzureServiceBusConnectionString=@Microsoft.KeyVault(SecretUri=$ServiceBusConnStrKeyURL"")"

#LUIS Resources

az cognitiveservices account create -n $LuisAuthoringName -g $MyResourceGroup --kind LUIS.Authoring --sku F0 -l westus --yes
az cognitiveservices account create -n $LuisPredictionName -g $MyResourceGroup --kind LUIS --sku S0 -l westus --yes

$LuisAuthoringKey=$(az cognitiveservices account keys list --name $LuisAuthoringName -g $MyResourceGroup --query "key1" --output tsv)
$LuisPredKey=$(az cognitiveservices account keys list --name $LuisPredictionName -g $MyResourceGroup --query "key1" --output tsv)
$luisEndpoint=$(az cognitiveservices account show --name $LuisAuthoringName --resource-group $MyResourceGroup --query "properties.endpoints.LUIS" --output tsv)

az keyvault secret set --vault-name $KeyVaultName --name "BotName" --value $BotName
az keyvault secret set --vault-name $KeyVaultName --name "cosmosDbAuthKey" --value $CosmosPrimMasterKey
az keyvault secret set --vault-name $KeyVaultName --name "cosmosDBEndpoint" --value $CosmosEndpoint
az keyvault secret set --vault-name $KeyVaultName --name "environmentName" --value "prod"
az keyvault secret set --vault-name $KeyVaultName --name "LuisAuthoringKey" --value $LuisAuthoringKey
az keyvault secret set --vault-name $KeyVaultName --name "luisEndpoint" --value $luisEndpoint
az keyvault secret set --vault-name $KeyVaultName --name "LuisEndpointKey" --value $LuisPredKey
az keyvault secret set --vault-name $KeyVaultName --name "ResourceGroupName" --value $MyResourceGroup
az keyvault secret set --vault-name $KeyVaultName --name "WebAppName" --value $BotFrameworkBackEnd
az keyvault secret set --vault-name $KeyVaultName --name "LuisPredictionName" --value $LuisPredictionName
az keyvault secret set --vault-name $KeyVaultName --name "Web-Bot-WebChannel-Key" --value $WebBotWebChannelKey
az keyvault secret set --vault-name $KeyVaultName --name "WebChatBotName" --value $BotName

#az keyvault secret set --vault-name $KeyVaultName --name "MicrosoftAppId" --value $AppRegistrationID
#az keyvault secret set --vault-name $KeyVaultName --name "MicrosoftAppPassword" --value $AppRegistrationPassword





