source ./secrets
source ./parameters

# create RG
az group create --name $RESOURCE_GROUP --location $LOCATION
SP_OUTPUT=$(az ad sp create-for-rbac --scopes subscriptions/$SUBSCRIPTION_ID --name $SERVICE_PRINCIPIAL_NAME --role contributor)
echo $SP_OUTPUT >> secrets.sp 

# create SP with contributor role
SERVICE_PRINCIPIAL_ID=$(echo $SP_OUTPUT | grep -o '"appId": "[^"]*' | sed 's/"appId": "//')

# add SP a role of owner of RG
az role assignment create --assignee $SERVICE_PRINCIPIAL_ID --role Owner --scope subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP
az role assignment list --assignee $SERVICE_PRINCIPIAL_ID --all

# prepare script for VM to run on startup
export GITLAB_RUNNER_TOKEN=$GITLAB_RUNNER_TOKEN
envsubst < $RUNNER_SCRIPT_TEMPLATE_FILE > $RUNNER_SCRIPT_FILE

#create SA
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS --allow-blob-public-access

#create SA container
az storage container create --name $SA_CONTAINER --account-name $STORAGE_ACCOUNT --public-access blob

#upload script to blob storage
az storage blob upload --account-name $STORAGE_ACCOUNT --container-name $SA_CONTAINER --name $RUNNER_SCRIPT_FILE --file $RUNNER_SCRIPT_FILE --overwrite

# remove script from local 
rm runner_install.sh

# create VM
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$VM_TEMPLATE_FILE" \
  --parameters vmName="${VM_NAME}" \
               adminUsername="${VM_ADMIN_USERNAME}" \
               adminPassword="${VM_ADMIN_PASSWORD}" \
               networkInterfaceName="myNetworkInterface" \
               virtualNetworkName="myVNet" \
               subnetName="mySubNet" \
               publicIpName="myPublicIp" \
               domainNameLabel="${MAINSCOPE}" \
               scriptUri="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${SA_CONTAINER}/${RUNNER_SCRIPT_FILE}" \
               scriptFileName="${RUNNER_SCRIPT_FILE}" \
               customData="#cloud-config\nruncmd:\n  - echo 'Custom data script executed'"
               
               
   #configure JIT access to VM
   az security vm jit-policy set --resource-group $RESOURCE_GROUP --vm-name $VM_NAME --ports 22=22 --max-request-access-duration PT1H
   
   #configure JIT access to VM
   vm_ip=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --show-details --query publicIps -o tsv)
   
   #connect to newly created VM via SSH
   ssh adminUser@$vm_ip