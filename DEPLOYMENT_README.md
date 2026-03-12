# CI/CD Quickstart

## Prerequisites

1. Deploy the infrastructure in `infra/` (e.g. via `azd up`) so the resource group, ACR, and App Service exist.
2. Create a Microsoft Entra ID **app registration** with federated credentials for GitHub Actions OIDC. Grant it **AcrPush** on the container registry and **Contributor** on the App Service (or scoped to the resource group).

## GitHub Secrets (Settings → Secrets and variables → Actions → Secrets)

| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | Application (client) ID of the service principal |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

## GitHub Variables (Settings → Secrets and variables → Actions → Variables)

| Variable | Value | Example |
|---|---|---|
| `AZURE_CONTAINER_REGISTRY_NAME` | ACR short name (used for `az acr login`) | `acrabc123` |
| `AZURE_CONTAINER_REGISTRY_ENDPOINT` | ACR login server | `acrabc123.azurecr.io` |
| `AZURE_APP_SERVICE_NAME` | App Service resource name | `app-abc123` |

> **Tip**: After running `azd up`, find these values in the Azure Portal or via `azd env get-values`.

## Usage

Push to `main` or trigger the workflow manually from the **Actions** tab. The workflow builds the Docker image, pushes it to ACR, and deploys it to the App Service.
