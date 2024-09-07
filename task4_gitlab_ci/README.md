# Task

Write a pipeline using GitLab CI
Repository: https://gitlab.com/gcorpcity122/backend-application
It should include the following stages:
- Static code analysis using SonarQube
- Application build, after a successful build, push the resulting image to a Docker registry (Nexus Sonatype)
- Deployment of the application to a remote server (you can configure a TCP socket on the Docker server or deploy via SSH).
Also you need setup DB for application. The environment variables are the same as for the previous assignment.
- A successful result will be the opening of the application's Swagger: http://IP_REMOTE_SERVER/URL:8080/swagger-ui/index.html#/

In SonarQube and Nexus, the project name should be yourlastname-backend
For this task, you will need two virtual machines: one for the GitLab Runner and the other for deploying the application.

# 💡 Notes and Ideas

## Create Service Principial

[Reference](https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?tabs=bash)

But mind you, that there is an error, there is no need for leading `/` before subscriptions

`$ az ad sp create-for-rbac --scopes subscriptions/<subscription> --name "gitlab-ci-service-principial" --role contributor`

And then to enable pushing to ACR:

`az role assignment create 
--assignee <service-principal-id> 
--scope subscriptions/<subscription> --role AcrPush`

The output will be:

```
{
  "appId": "myServicePrincipalId",
  "displayName": "myServicePrincipalName",
  "password": "myServicePrincipalPassword",
  "tenant": "myOrganizationTenantId"
}
```

To login use:

```
az login --service-principal \
--username <appId> \
--password <password> \
--tenant <tenantId>
```

## ACR Creation
Since AKS requires to have ACR ImagePull role it tries to assign this itself. But in this case it requires Owner 
Role of the overall subsription. In order to avoid this it's better to create RG, ACR in advance and grant this role.

`az role assignment create --assignee <service-principal-object-id> --scope <RegistryID> --role AcrPull`

az role assignment create --assignee <SP-ID> --scope 
    subscriptions/<SUBSCRIPTION-ID>/resourceGroups/<RESOURCE-GROUP>/providers/Microsoft.
ContainerRegistry/registries/<ACR-NAME> --role AcrPull

## Login in Gitlab CI

This CI stage deploys a resource group after authentication process. Create CI variables in gitlab.

```
deploy_rg:
  image: mcr.microsoft.com/azure-cli
  stage: deploy
  script:
    - az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
    - az account set --subscription $AZURE_SUBSCRIPTION_ID
    - az group create --name devopsschool4 --location polandcentral
    - echo "RG was created successfully"
```


