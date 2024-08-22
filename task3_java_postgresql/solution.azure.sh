# import parameters
source "./parameters.sh"

# prepare image locally
sh solution.local.sh --local-run skip

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

az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az acr login --name $ACR_NAME
az acr update -n $ACR_NAME --admin-enabled true
docker tag $IMAGE_NAME $PUBLIC_IMAGE
docker push $PUBLIC_IMAGE

# prepare db image
docker pull $DB_IMAGE
docker tag $DB_IMAGE $PUBLIC_DB_IMAGE 
docker push $PUBLIC_DB_IMAGE

az acr credential show --name devopsschoolacr
az acr login --name $ACR_NAME

if check_image_ready; then
  az aks create -g $RESOURCE_GROUP -n $AKS_NAME --attach-acr $ACR_NAME --generate-ssh-keys
  kubectl config delete-context $AKS_NAME
  kubectl config unset clusters.$AKS_NAME
  kubectl config unset users.$AKS_NAME
  kubectl config unset "users.clusterUser_${RESOURCE_GROUP}_${AKS_NAME}"
  kubectl config unset users.clusterUser_$AKS_NAME
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
  
  # prepare environment to substitute variables in manifests
  export PUBLIC_IMAGE=$PUBLIC_IMAGE
  export PUBLIC_DB_IMAGE=$PUBLIC_DB_IMAGE
  export DB_NAME=$DB_NAME
  export DB_USERNAME=$DB_USERNAME
  export DB_PASSWORD=$DB_PASSWORD
  envsubst < manifest-app.yaml | kubectl apply -f -
  envsubst < manifest-postgres.yaml | kubectl apply -f -
  echo "done successfully "
else
  echo "deployment failed because the image is not ready at ACR"
fi

# cleanup (remove RG)
# az group delete --name $RESOURCE_GROUP

# try to include parameters
