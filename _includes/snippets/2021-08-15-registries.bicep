
// Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
param acrName string = replace(replace(resourceGroup().name, 'rg-', 'acr'), '-', '')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param skuName string = 'Basic'
param deployReplication bool = false
param replicationLocation string = 'northeurope'
param replicationName string = 'northeurope'

// Create Azure Container Registry resource
resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: false
  }
}

// Deploy replication resource conditionally
resource replication 'Microsoft.ContainerRegistry/registries/replications@2021-06-01-preview' = if (deployReplication) {
  parent: registry
  name: replicationName
  location: replicationLocation
  properties: {
    zoneRedundancy: 'Disabled' // Zone redundancy is still on preview
  }
}

output name string = registry.name
output id string = registry.id
