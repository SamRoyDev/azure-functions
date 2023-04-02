# Deployment Notes

az login

# Variables
ResourceGroup="MyResourceGroup"
Location="EastUS"
StorageAccount="mystorageaccount"

# Create a new Resource Group
az group create --name $ResourceGroup --location $Location

# Create a new Storage Account
az storage account create --name $StorageAccount --location $Location --resource-group $ResourceGroup --sku Standard_LRS --kind StorageV2

# Variables
FunctionAppName="GetMailboxFunctionApp"

# Create a new Function App
az functionapp create --name $FunctionAppName --storage-account $StorageAccount --resource-group $ResourceGroup --consumption-plan-location $Location --runtime powershell --functions-version 3

# Deploy your function from your Git repo
az functionapp deployment source config --name $FunctionAppName --resource-group $ResourceGroup --repo-url <your_git_repo_url> --branch master --manual-integration

# Securing the App

### Update the Function App's auth settings
az webapp auth update --ids $(az functionapp show --name $FunctionAppName --resource-group $ResourceGroup --query id --output tsv) --enabled true --action LoginWithAzureActiveDirectory --aad-allowed-token-audiences <your_client_id>


# Example config.yml that could deploy this:

version: 2.1
orbs:
  azure-cli: circleci/azure-cli@1.3.0

jobs:
  deploy:
    docker:
      - image: circleci/python:3.7
    steps:
      - checkout
      - azure-cli/install
      - azure-cli/login-with-service-principal:
          client-id: $AZURE_CLIENT_ID
          client-secret: $AZURE_CLIENT_SECRET
          tenant-id: $AZURE_TENANT_ID
      - run:
          name: Deploy Azure Function
          command: |
            # Variables
            ResourceGroup="MyResourceGroup"
            Location="EastUS"
            StorageAccount="mystorageaccount"
            FunctionAppName="GetMailboxFunctionApp"

            # Create a new Resource Group
            az group create --name $ResourceGroup --location $Location

            # Create a new Storage Account
            az storage account create --name $StorageAccount --location $Location --resource-group $ResourceGroup --sku Standard_LRS --kind StorageV2

            # Deploy the ARM template
            az deployment group create --resource-group $ResourceGroup --template-file azuredeploy.json --parameters functionAppName=$FunctionAppName storageAccountName=$StorageAccount location=$Location aadClientId=$AAD_CLIENT_ID

            # Deploy your function from your Git repo
            az functionapp deployment source config --name $FunctionAppName --resource-group $ResourceGroup --repo-url $CIRCLE_REPOSITORY_URL --branch master --manual-integration

workflows:
  version: 2
  deploy:
    jobs:
      - deploy
