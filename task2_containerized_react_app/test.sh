# define variables
RESOURCE_GROUP="devopsschool2"
LOCATION="polandcentral"
TAGS="Area=DevOpsSchool"
ACR_NAME="devopsschoolacr"
IMAGE_NAME="react-app-nginx"
PUBLIC_IMAGE="$ACR_NAME.azurecr.io/$IMAGE_NAME:latest"
DNS_LABEL="devopsschool2"
CONTAINER_NAME="devopsschool2"
TEMPLATE_FILE="template.json"

# function to check if the image is ready
check_image_ready() {
  echo "wait until image is available"
  sleep 30
  for i in {1..5}; do
    if az acr repository show-tags --name $ACR_NAME --repository $IMAGE_NAME --output table | grep -q "latest"; then
      echo "image is ready."
      return 0
    else
      echo "image not ready yet. Retrying in 30 seconds..."
      sleep 30
    fi
  done
  echo "image is still not ready after retries."
  return 1
}

# create RG
az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az acr credential show --name devopsschoolacr
az acr login --name $ACR_NAME
az acr update -n $ACR_NAME --admin-enabled true
docker tag $IMAGE_NAME $PUBLIC_IMAGE
docker push $PUBLIC_IMAGE
az acr credential show --name devopsschoolacr
az acr login --name $ACR_NAME
# az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE

if check_image_ready; then
  az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE
else
  echo "deployment failed because the image is not ready at ACR"
  exit 1
fi

# diagnostics
# az container show --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP

# cleanup (remove RG)
# az group delete --name $RESOURCE_GROUP

#Before fetching credentials enable admin