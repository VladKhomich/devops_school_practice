# variables import
source "./parameters.sh"

# read PAT token
if [ -f "$TOKEN_FILE" ]; then
    GITLAB_TOKEN=$(cat "$TOKEN_FILE")
else
    echo "Token file not found!"
    exit 1
fi

# clone repo
FULL_REPO_URL="https://$GIT_USER_NAME:${GITLAB_TOKEN}@$REPO_URL"
git clone --depth=1 $FULL_REPO_URL $REPO_DIR

# docker step
docker-compose up --build

# clean up (remove temp directory)
rm -rf $TEMP_DIR
