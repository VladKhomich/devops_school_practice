sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

sudo chmod +x /usr/local/bin/gitlab-runner

sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com" \
  --registration-token $GITLAB_RUNNER_TOKEN \
  --description "My GitLab Runner" \
  --executor "shell" \
  --tag-list "shell,azure" \
  --run-untagged="true" \
  --locked="false"

gitlab-runner run