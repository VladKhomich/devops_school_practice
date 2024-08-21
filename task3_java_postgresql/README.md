# Notes

## Task
Java backend repository
https://gitlab.com/gcorpcity122/backend-application
For this backend, a PostgreSQL database is required (version 12 is acceptable).
Java version 17.
The application port is 8080.
Additionally, application credentials need to be passed through environment variables (use a file in Docker Compose)
QA_COURSE_01_RDS_DB_NAME=
QA_COURSE_01_RDS_USERNAME=
QA_COURSE_01_RDS_PASSWORD=
QA_COURSE_01_RDS_DB_HOST=
The build is done using Maven.
The command for the build mvn clean install -Dmaven.test.skip
The artifact will be located in the folder target/
You need to write a Dockerfile with a multi-stage build (the first stage being Maven-Java, and the second one copying the artifact into a container with Java 17).
Then, using Docker Compose, you'll bring up the application and a PostgreSQL database.

A successful result will be the opening of the application's Swagger: http://localhost:8080/swagger-ui/index.html#/

Setup project localy

## Solution 🧩

The task is solved (or at least it's planned to be solved) in two variations: local setup and Microsoft Azure)

### Cloud-based Solution

💡 Draft ideas:

- clone repo from git to my local machine with PAT
- containerize it (create image of java app and postgress db)
- create azure RG
- create azure ACR
- create AKS
- push containers into ACR
- attach ACR to AKS
- apply manifest

### Local Solution 💻

(make sure to add your PAT as it's mentioned at pat.token.default)

`sh solution.local.sh`

#### Cleanup 🧹
`rm -rf $TEMP_DIR`

#### Description 📝

Actions that are performed:
1. get PAT from file
2. clone last revision of remote repo to temp folder
3. create network
4. build postrgress container
5. build API container with maven
6. run containers

Then the website can be accessed [locally](http://localhost:8080/swagger-ui/index.html)

## Notes and Ideas 💡

[Deploy AKS with CLI](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli)

get credentials for AKS
`az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME`

get nodes of AKS
`kubectl get nodes`

apply manifest:
`kubectl apply -f manifest.yaml`

get pod logs
`kubectl logs <postgres-pod-name>`