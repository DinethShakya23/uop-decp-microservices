# Multi-stage build for Auth Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY auth-service/pom.xml ./auth-service/pom.xml
RUN mvn -f ./auth-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY auth-service/src ./auth-service/src
RUN mvn -f ./auth-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/auth-service/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
