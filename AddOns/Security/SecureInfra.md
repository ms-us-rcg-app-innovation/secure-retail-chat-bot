<!-- ABOUT THE PROJECT -->
# About This Module

The purpose of this module is to add a few layers of security to our Bot

# Can I block all traffic to my bot except traffic from the Bot Framework Service?

Bot Framework Services is hosted in Azure data centers world-wide and the list of Azure IPs is constantly changing. That means allow-listing certain IP addresses may work one day and break the next as the Azure IP Addresses change.

We can however limit exposure by only allowing traffic originating from the Azure Cloud through the use of Azure Service Tags, in this case AzureCloud.

```shell
az webapp config access-restriction add -g $MyResourceGroup -n $BotFrameworkBackEnd --priority 100 --service-tag AzureCloud
```

# Restricting traffic for Function API to only accept traffic from within the Vnet

Specify Variables if not continuing from the demo deployment

```shell
$Location = "westus"
$MyResourceGroup = "RetailChatBotResources-YourPostfix" # Name of Resource Group
$PrivateEndpointSubnet1 = "PrivateEndpointSubnet-YourPostfix" # Name of Private Endpoint Subnet
$VnetName = "retailbotVnetYourPostfix" # Name of the Vnet
$FunctionName = "botapi-YourPostfix"

$PrivateEndpointName = "SpecifyPrivateEndpointNameHere"
$PrivateEndpointConnectionName = "SpecifyPrivateEndpointConnNameHere"
```

Add Private Endpoint and Private DNS between the Azure Function and the Bot Code

```shell

az network private-dns zone create --resource-group $MyResourceGroup --name "privatelink.azurewebsites.net"
az network private-dns link vnet create --resource-group $MyResourceGroup --zone-name "privatelink.azurewebsites.net" --name MyDNSLink --virtual-network $VnetName --registration-enabled false

$PrivateDNSZoneID=$(az network private-dns zone show -g $MyResourceGroup -n "privatelink.azurewebsites.net" --query "id" --output tsv)

az network vnet subnet update --name $PrivateEndpointSubnet1 --resource-group $MyResourceGroup --vnet-name $VnetName --disable-private-endpoint-network-policies true

az network private-endpoint create -g $MyResourceGroup -n $PrivateEndpointName --vnet-name $VnetName --subnet $PrivateEndpointSubnet1 --private-connection-resource-id $FunctionResourceID --connection-name $PrivateEndpointConnectionName -l $Location --group-id sites
az network private-endpoint dns-zone-group create --endpoint-name $PrivateEndpointName -g $MyResourceGroup -n default --zone-name "privatelink.azurewebsites.net" --private-dns-zone $PrivateDNSZoneID

```
The Azure Function will no longer be accessible via the internet. Bot should function without interruption. This configuration will also affect your CICD pipeline. To avoid any CICD issues, using private agent is recommended.

# Direct Line Extension - Available for web chat channel

The Direct Line App Service extension allows clients to connect directly with the host (AppService in this case)

https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-directline-extension-net-bot?view=azure-bot-service-4.0

https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-directline-extension-webchat-client?view=azure-bot-service-4.0


[Return to Main ReadMe](../../README.md)