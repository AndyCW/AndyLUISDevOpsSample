#!/bin/bash
# Get the Service Principal name
SP_DEFAULT="myLUISDevOpsApp"
read -p "Enter the Service Principal name [$SP_DEFAULT]: " spname
spname="${spname:-$SP_DEFAULT}"

# Get the resource group name
RG_DEFAULT="luisDevOpsRG"
read -p "Enter the Azure Resource Group name [$RG_DEFAULT]: " resourceGroup
resourceGroup="${resourceGroup:-$RG_DEFAULT}"

# Get the storage acount name
STORAGE_DEFAULT="luisdevopsresultsstorage"
read -p "Enter the Azure Storage Account name [$STORAGE_DEFAULT]:" storageAccount
storageAccount="${storageAccount:-$STORAGE_DEFAULT}"

# get the app id of the service principal
servicePrincipalAppId=$(az ad sp list --display-name $spname --query "[].appId" -o tsv)

# view the default role assignment (it will be owner access to the whole subscription)
az role assignment list --assignee $servicePrincipalAppId

# get the id of that default assignment
roleId=$(az role assignment list --assignee $servicePrincipalAppId --query "[].id" -o tsv)

# delete that role assignment
az role assignment delete --ids $roleId

# get our subscriptionId
subscriptionId=$(az account show --query id -o tsv)

# grant contributor access just to this resource group only
az role assignment create --assignee $servicePrincipalAppId \
        --role "contributor" \
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"

# Get the Storage Subscription id
storageSubscriptionId=$(az storage account show --resource-group $resourceGroup --name $storageAccount --query "[].id" -o tsv)

# grant Storage Blob Data Contributor access just to this resource group
az role assignment create --assignee $servicePrincipalAppId \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup" 

az role assignment list --assignee $servicePrincipalAppId --all