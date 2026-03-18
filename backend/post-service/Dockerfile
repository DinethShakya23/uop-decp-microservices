# Multi-stage build for Post Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY post-service/pom.xml ./post-service/pom.xml
RUN mvn -f ./post-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY post-service/src ./post-service/src
RUN mvn -f ./post-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/post-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
