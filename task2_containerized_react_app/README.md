# Notes

## Task
There is a React application at 
https://gitlab.com/gcorpcity122/frontend-application 
Create a Dockerfile with multi-stage build (first stage node build static, second - copy static files to nginx container) 
 You can use Node.js version 20.
 For build static use command npm run build
 Artifact will be available in folder dist
Run the application in a docker container on host port 84.
Result - http://localhost:84 - frontend page

## 💡 Ideas

Deploy everything to Azure Container Apps

## Solution

`sh solution.sh`

### Description
1. get PAT from file
2. clone last revision of remote repo to temp folder
3. build container
4. start container

