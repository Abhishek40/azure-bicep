## Deployment command to deploy Bicep file
```Bash
az deployment group create --template-file azuredeploy.bicep --resource-group myResourceGroup
```
```Bash
az bicep --help

## Resource List
az resource list --resource-group exampleRG

## concat in parameters
param name string
 
param location string = 'westus2'
 
var stgAcctName = concat(name, '2468')
var stgAcctName = '${name}2468'
```
```Bash
## ubuntu_vm.bicep
az group create --name ubuRG --location eastus

az deployment group create --resource-group ubuRG --template-file ubuntu_vm.bicep --parameters adminUsername=<admin-username>

az group delete --name ubuRG
```
