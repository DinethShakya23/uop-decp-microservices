# Multi-stage build for Job Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY job-service/pom.xml ./job-service/pom.xml
RUN mvn -f ./job-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY job-service/src ./job-service/src
RUN mvn -f ./job-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/job-service/target/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
