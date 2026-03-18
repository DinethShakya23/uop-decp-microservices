# Multi-stage build for Notification Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY notification-service/pom.xml ./notification-service/pom.xml
RUN mvn -f ./notification-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY notification-service/src ./notification-service/src
RUN mvn -f ./notification-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/notification-service/target/*.jar app.jar
EXPOSE 8088
ENTRYPOINT ["java", "-jar", "app.jar"]
