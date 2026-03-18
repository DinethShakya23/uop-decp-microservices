# Multi-stage build for Event Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY event-service/pom.xml ./event-service/pom.xml
RUN mvn -f ./event-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY event-service/src ./event-service/src
RUN mvn -f ./event-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/event-service/target/*.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "app.jar"]
