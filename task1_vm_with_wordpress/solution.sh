# define variables
VM_NAME="myWordPressVM"
RESOURCE_GROUP="devopsschool1"
STORAGE_ACCOUNT="devopsschool1sa"
SA_CONTAINER="devopsschool1container"
LOCATION="polandcentral"
TEMPLATE_FILE="template.json"
PARAMETERS_FILE="parameters.json"
VM_SETUP_SCRIPT="install_wordpress.sh"
TAGS="Area=DevOpsSchool"

#create RG
az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS

#create SA
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS --allow-blob-public-access

#create SA container
az storage container create --name $SA_CONTAINER --account-name $STORAGE_ACCOUNT --public-access blob

#upload script to blob storage
az storage blob upload --account-name $STORAGE_ACCOUNT --container-name $SA_CONTAINER --name $VM_SETUP_SCRIPT --file $VM_SETUP_SCRIPT

#deploy ARM template
az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

#configure JIT access to VM
az security vm jit-policy set --resource-group $RESOURCE_GROUP --vm-name $VM_NAME --ports 22=22 --max-request-access-duration PT1H

#configure JIT access to VM
vm_ip=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --show-details --query publicIps -o tsv)

#connect to newly created VM via SSH
ssh adminUser@$vm_ip