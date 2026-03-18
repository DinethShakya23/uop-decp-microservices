# Multi-stage build for Messaging Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY messaging-service/pom.xml ./messaging-service/pom.xml
RUN mvn -f ./messaging-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY messaging-service/src ./messaging-service/src
RUN mvn -f ./messaging-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/messaging-service/target/*.jar app.jar
EXPOSE 8087
ENTRYPOINT ["java", "-jar", "app.jar"]
