<!-- ABOUT THE PROJECT -->
# About This Module

This module will provide information on setting up a custom agent for your pipeline. This is recommended when using the bot with vnet integration. This guide is for an Ubuntu based VM.

## Create your Azure DevOps Self Hosted Agent

https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops

Once installed, install the following dependencies:

```shell
# Update the list of packages
sudo apt-get update

# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common

# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Install Zip
sudo apt-get install zip

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```


