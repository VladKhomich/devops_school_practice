# build React app
FROM node:20 as build
WORKDIR /app
COPY temp/app/package*.json ./

RUN npm install

COPY temp/app/. .
RUN npm install
RUN npm run build

# serve
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]