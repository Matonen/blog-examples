# Blog Examples

This repository contains code examples and projects referenced in blog posts, demonstrating Azure infrastructure deployment, Microsoft Fabric CI/CD, and containerized development workflows.

## 🚀 Quick Start

### Dev Container Setup

This repository includes a pre-configured dev container with all necessary tools:

**To use:**

1. Open repository in VS Code
2. When prompted, click "Reopen in Container"
3. Or use: `F1` → "Dev Containers: Reopen in Container"

### Prerequisites (Outside Container)

- Visual Studio Code with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker Desktop

## 🛠️ Deployment Guide

### Deploy Azure Infrastructure

1. **Login to Azure:**

   ```bash
   az login
   ```

2. **Navigate to the stack directory:**

   ```bash
   cd infra/bicep/stacks/{stack}
   ```

3. **Preview changes (recommended):**

   ```bash
   az deployment sub what-if \
     --subscription {subscription} \
     --location {location} \
     --template-file main.bicep \
     --parameters {env}.bicepparam
   ```

4. **Deploy the stack:**

   **For most stacks (using deployment stacks):**

   ```bash
   az stack sub create \
     --name {stack} \
     --subscription {subscription} \
     --location {location} \
     --deny-settings-mode none \
     --action-on-unmanage detachAll \
     --template-file main.bicep \
     --parameters {env}.bicepparam
   ```

   **For `fabric-mirroring` stack (uses Microsoft Graph Bicep):**

   ```bash
   az deployment sub create \
     --subscription {subscription} \
     --location {location} \
     --template-file main.bicep \
     --parameters {env}.bicepparam
   ```

   > **Note:** Deployment stacks are not supported with Microsoft Graph Bicep extensions, so `fabric-mirroring` uses standard deployment commands.

**Parameters to replace:**

- `{stack}` - Stack name (e.g., `cosmosdb-rbac`, `fabric-mirroring`)
- `{subscription}` - Your Azure subscription ID or name
- `{location}` - Azure region (e.g., `eastus`, `westeurope`)
- `{env}` - Environment name (e.g., `sbx`, `dev`, `prod`)

### Deploy Microsoft Fabric Items

Deploy Fabric notebooks, pipelines, and other items to a workspace:

```bash
cd fabric
python deploy_fabric_items.py \
  --workspace_id {workspace-guid} \
  --environment prod \
  --source_directory {workspace-name}
```

**Optional:** Filter by item types:

```bash
python deploy_fabric_items.py \
  --workspace_id {workspace-guid} \
  --environment prod \
  --source_directory {workspace-name} \
  --items_in_scope "notebook,pipeline"
```

Omit `--items_in_scope` to deploy all item types.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
