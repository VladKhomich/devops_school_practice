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

# create RG
az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az acr login --name $ACR_NAME
az acr update -n $ACR_NAME --admin-enabled true
docker tag $IMAGE_NAME $PUBLIC_IMAGE
docker push $PUBLIC_IMAGE
az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE

# cleanup (remove RG)
# az group delete --name $RESOURCE_GROUP