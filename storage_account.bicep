@description('Storage Account Name')
param storageAccountName string = 'Storage21-${uniqueString(resourceGroup().id)}'

@description('Location where create storage account')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
@description('List of storage Account type')
param storageType string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageType
  }
  kind: 'StorageV2'
  properties: {}
}
