# first stage: build  using Maven
FROM maven:3.8.5-eclipse-temurin-17 AS build

WORKDIR /app

COPY temp/app/pom.xml ./
COPY temp/app/src ./src

RUN mvn clean install -Dmaven.test.skip

# second stage: create final image with built artifact
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# copy artifact from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
