### Sign in to Azure with Azure CLI

In the Visual Studio Code terminal, sign in to Azure by running the following command:

`az login`

In the browser that opens, sign in to your Azure account.

The Visual Studio Code terminal displays a list of the subscriptions associated with this account.

Set the subscription context for all of the Azure CLI commands that you run in this session.

`az account set --subscription "your-subscription-name"`