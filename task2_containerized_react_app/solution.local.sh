# variables import
source "./parameters.sh"

LOCAL_RUN="run"

# get parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --local-run) LOCAL_RUN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

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
docker build -t react-app-nginx .

if [ $LOCAL_RUN != "skip" ]; then
  docker run -p 84:80 -d react-app-nginx
fi

# clean up (remove temp directory)
rm -rf $TEMP_DIR

exit 1
