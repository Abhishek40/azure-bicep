//https://learn.microsoft.com/en-us/azure/nat-gateway/quickstart-create-nat-gateway-bicep?toc=%2Fazure%2Fazure-resource-manager%2Fbicep%2Ftoc.json&tabs=CLI

/*
This Bicep file deploys a virtual network, a NAT gateway resource, and Ubuntu virtual machine.
The Ubuntu virtual machine is deployed to a subnet that is associated with the NAT gateway resource

This Bicep file is configured to create a:

1. Virtual network
2. NAT gateway resource
3. Ubuntu virtual machine
*/

@description('The name virtual machine')
param vmName string = 'vm21'

@description('Size of VM')
param vmSize string = 'Standard_D2s_v3'

@description('The name of Virtual Network')
param vnetName string = 'vnet-21'

@description('Name of the subnet for virtual network')
param subnetName string = 'subnet-21'

@description('Address space for virtual network')
param vnetAddressSpace string = '10.0.0.0/16'

@description('Subnet prefix for virtual network')
param vnetSubnetPrefix string = '10.0.0.0/24'

@description('Name of NAT Gateway')
param natGatewayName string = 'nat-21'

@description('Name of the virtual machine nic')
param networkInterfaceName string = 'nic-21'

@description('Name of the NAT gateway public IP')
param publicIpName string = 'public-ip-nat'

@description('Name of the virtual machine NSG')
param nsgName string = 'nsg-21'

@description('Administrator username for virtual machine')
param adminUserName string

@description('Administrator password for virtual machine')
@secure()
param adminPassword string

@description('Location of resource group')
param location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: {
    Name: 'ngs-21'
  }
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 300
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  tags: {
    Name: publicIpName
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    deleteOption: 'Delete'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  tags: {
    Name: vmName
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: 'Linux'
        name: '${vmName}_Disk1'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 20
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: {
    Name: 'vnet21'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: vnetSubnetPrefix
          natGateway: {
            id: natgateway.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource natgateway 'Microsoft.Network/natGateways@2023-05-01' = {
  name: natGatewayName
  location: location
  tags: {
    Name: 'NAT-21'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicip.id
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: vnetSubnetPrefix
    natGateway: {
      id: natgateway.id
    }
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkinterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ni-21'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}
