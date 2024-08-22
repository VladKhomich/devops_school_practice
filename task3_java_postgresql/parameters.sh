# gitlab
TOKEN_FILE=pat.token
TEMP_DIR="temp"
REPO_DIR="$TEMP_DIR/app"
REPO_URL="gitlab.com/gcorpcity122/backend-application"
GIT_USER_NAME="vladislav.builder"

#compose
DB_NAME="mydatabase"
DB_USERNAME="myuser"
DB_PASSWORD="password123"

# azure
RESOURCE_GROUP="devopsschool3"
LOCATION="polandcentral"
TAGS="Area=DevOpsSchool"
ACR_NAME="devopsschoolacr"
AKS_NAME="devopsschoolaks"
IMAGE_NAME="task3_java_postgresql-java-app"
PUBLIC_IMAGE="$ACR_NAME.azurecr.io/$IMAGE_NAME:latest"
DB_IMAGE="postgres:13"
DB_IMAGE_NAME="my_db"
PUBLIC_DB_IMAGE="$ACR_NAME.azurecr.io/$DB_IMAGE_NAME:latest"
DNS_LABEL="devopsschool3"
TEMPLATE_FILE="template.json"
