# Multi-stage build for User Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY user-service/pom.xml ./user-service/pom.xml
RUN mvn -f ./user-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY user-service/src ./user-service/src
RUN mvn -f ./user-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/user-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
