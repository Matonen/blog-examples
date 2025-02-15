# Blog Examples

This repository contains code examples and projects referenced in blog posts.

## Overview

These examples are designed for developers deploying Azure resources using the Azure CLI and Bicep. Each example is categorized under relevant topics within the repository.

## Prerequisites

- Visual Studio Code
- Azure CLI

## Deploy Azure Infra

Follow these steps to deploy solutions to Azure:

1. Open a terminal
2. Log in using your Microsoft Entra ID credentials:

    ```shell
    az login
    ```

3. Navigate to the directory:

    ```shell
    cd infra/bicep/stacks/{stack}
    ```

4. Verify the changes using the what-if command:

    ```shell
    az deployment sub what-if --subscription {subscription} --location {location} --template-file main.bicep --parameters {env}.bicepparam
    ```

5. Deploy the stack:

    ```shell
    az stack sub create --name {stack} --subscription {subscription} --location {location} --deny-settings-mode none --action-on-unmanage deleteAll --template-file main.bicep --parameters {env}.bicepparam
    ```

*Replace placeholders (e.g., {stack}, {subscription}, {location}, {env}) with your actual parameters.*

## License

This project is licensed under the MIT License.
