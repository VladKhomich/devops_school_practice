# gitlab
TOKEN_FILE=pat.token
TEMP_DIR="temp"
REPO_DIR="$TEMP_DIR/app"
REPO_URL="gitlab.com/gcorpcity122/backend-application"
GIT_USER_NAME="vladislav.builder"

# azure
RESOURCE_GROUP="devopsschool2"
LOCATION="polandcentral"
TAGS="Area=DevOpsSchool"
ACR_NAME="devopsschoolacr"
IMAGE_NAME="react-app-nginx"
PUBLIC_IMAGE="$ACR_NAME.azurecr.io/$IMAGE_NAME:latest"
DNS_LABEL="devopsschool2"
CONTAINER_NAME="devopsschool2"
TEMPLATE_FILE="template.json"