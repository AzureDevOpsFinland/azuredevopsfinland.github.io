---
layout: single
title:  "Create Geo-Replicated Azure Container Registry with Bicep"
date:   2021-08-15 11:30:00 +3:00
tag: bicep azure containers devops
toc: true
toc_sticky: true
read_time: true
excerpt: "In this post we create _Geo-Replicated_ _Azure Container Registry_ with Premium Tier using Bicep template."
header:
  overlay_color: "#000"
  overlay_filter: "0.7"
  overlay_image: /assets/images/overlays/overlay-acr-georeplicate-1.png
---

In this post we create Geo-Replicated [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro) (ACR) with Premium Tier using [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) templates.

> Azure Container Registry (ACR) is a Platform as a Service product for storing and managing _private Docker container images_. Azure container registries can include both Windows and Linux images. Typical architecture scanario for ACR usage is to simplify the deployment and management of [microservices-based architecture](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/microservices-with-aks).
{: .notice--primary}

## Geo-replication - network-close approach

Good practice is to keep a container registry near the data center where images are managed and run. For globally distributed Docker image based applications Azure Container Registry's _Geo-replication_ enables serving multiple regions with multi-master regional registries:

![ACR georeplicate use case](/assets/images/overlays/overlay-acr-georeplicate-1.png)

- Single registry, image, and tag names can be used across multiple regions.
- Network-close registry access.
- Single management of a registry across multiple regions.
- Registry resilience if a regional outage occurs.

## Review registries.bicep Template

This Bicep template creates a [Microsoft.ContainerRegistry/registries](https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?tabs=bicep) resource and sub-resource [Microsoft.ContainerRegistry/registries/replications](https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/replications?tabs=bicep) for Geo-Replication. 

By default pricing tier is `Basic` tier resource instance but since we are doing Geo-Replication we need `Premium`tier. Hence, we will override the `skuName` parameter during deployment.

> 💡 TIP
>
> If you dont' need Geo-Replication use default `skuName` parameter. That will create a `Basic` tier registry, which is a cost-optimized option for developers learning about Azure Container Registry. Choose other tiers for increased storage and image throughput, and capabilities such as connection using a private endpoint. For details on available service tiers (SKUs), see [Container registry service tiers](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus).
{: .notice--info}

This template uses Bicep's [outside parent resource](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type#outside-parent-resource) syntax to reference parent of `replication` resource. I find this a really handy way to build up correct resource naming syntax for child resources: _Specify the parent property on the child with the value set to the symbolic name of the parent. With this syntax you still need to declare the full resource type, but the name of the child resource is only the name of the child_.

```yaml
{% include snippets/2021-08-15-registries.bicep %}
```

Notice that template uses boolean parameter and [conditional deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/conditional-resource-deployment#deploy-condition) logic `if (deployReplication)` to deploy replication to `northeurope` location.

> 🚩 NOTE - `adminUserEnabled: false`
>
> The admin account is designed for a single user to access the registry, mainly for testing purposes. Disable admin user for production usage and do not share admin account credentials among multiple users.
{: .notice--warning}


{% include deploy-template-to-azure-common.md %}}
1. Switch your terminal to the directory where you saved `registry.bicep` template.

{% include sign-in-to-azure.md %}

{% include create-resource-group-with-azure-cli.md %}

### Deploy registries.bicep template to Azure

Run the following command from the terminal in Visual Studio Code to deploy the Bicep template to Azure. 

`az deployment group create --template-file .\registries.bicep  --resource-group "rg-yourgroup-we-dev" --parameters skuName="Premium" deployReplication=true`

In the example above we are deploying template that creates premium tier Azure Container Registry resource with Geo-Replication location to development environment.

### Review deployed resources

Use the _Azure portal_ or a tool such as the _Azure CLI_ to review the properties of the container registry.

1. In the portal, search for _Container Registries_, and select the container registry you created.
1. On the Overview page, note the Login server of the registry. Use this URI when you use Docker to tag and push images to your registry. 

   ![search for container registries](/assets/images/2021-08-15-search-azure-portal-for-acr.png).

1. Select the ACR that you created.
1. Under _Services_ select _Replications_ and you should see something similar than below where West Europe data center has blue icon and North Europe has green icon.

   ![Geo-replicated ACR](/assets/images/2021-08-15-acr-replications-after-deployment.png)

**AZ-CLI - az acr show**

Get the details of an Azure Container Registry.

`az acr show --name "acryourgroupwedev"`

**Log in to registry with Azure CLI and Docker CLI**

Ensure that you can log in to the registry instance. Specify only the registry resource name when logging in with the Azure CLI. **Don't use the fully qualified login server name**.

**Azure CLI - az acr login**

If you have Docker installed and running you can try following command to login.

`az acr login --name "acryourgroupwedev"`

The command returns _Login Succeeded_ once completed.

If you don't have Docker installed or it's not running you can verify that you can get access token with command:

`az acr login --name "acryourgroupwedev" --expose-token`

`--expose-token` switch exposes an access token instead of logging in through the Docker CLI.

## See also

- Docker docs: [Docker overview](https://docs.docker.com/get-started/overview/).
- Azure Container Registry [roadmap](https://github.com/Azure/acr/blob/main/docs/acr-roadmap.md).
- Azure Updates related to [Container Registry](https://azure.microsoft.com/en-us/updates/?category=containers&query=Container%20Registry).
- Microsoft blogs tagger with [Azure Container Registry](https://azure.microsoft.com/en-us/blog/tag/azure-container-registry/).