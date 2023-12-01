#!/bin/bash

# FILL VARIABLES BELOW
subscriptionID="ENTER_YOUR_SUBSCRIPTION_ID"

# Login to Azure
az login

# Set the subscription
az account set --subscription "$subscriptionID"

# Define variables
resourceGroupName="nh-aks-as"
location="israelcentral"
aksClusterName="nh-aks"
armTemplatePath="template.json"
armParamsPath="parameters.json"
acrName="navehacr"

# Create a resource group
az group create --name $resourceGroupName --location $location
echo "Successfully created resource group"

# Deploy AKS Cluster using ARM Template
az deployment group create --resource-group $resourceGroupName --template-file $armTemplatePath --parameters $armParamsPath

# Access and configure kubectl
az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName

kubectl config use-context $aksClusterName

# Install helm chart for nginx ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

# Create ACR
az acr create --name $acrName --resource-group $resourceGroupName --location $location --sku Basic

# Log into the ACR instance
az acr login --name $acrName

# Build and upload the express app image
acrServer=$(az acr show --name $acrName)
az acr build -t btc-express:latest -r $acrName ./BTC_express_app/

# Assign owner role for cluster+agentpool within the scope of the ACR
clusterID=$(az aks show --resource-group "$resourceGroupName" --name $aksClusterName --query identity.principalId -o tsv)
agentpoolID=$(az aks show --resource-group "$resourceGroupName" --name $aksClusterName --query identityProfile.kubeletidentity.objectId -o tsv)
roleScope=$(az acr show --name $acrName --resource-group $resourceGroupName --query id --output tsv)

az role assignment create --assignee-object-id $clusterID --assignee-principal-type ServicePrincipal --role "Owner" --scope $roleScope
az role assignment create --assignee-object-id $agentpoolID --assignee-principal-type ServicePrincipal --role "Owner" --scope $roleScope

# Apply the deployment files
kubectl apply -f ./YAML/btc-config.yaml -f ./YAML/busybox-config.yaml -f ./YAML/networkPolicy.yaml -f ./YAML/ing.yaml
