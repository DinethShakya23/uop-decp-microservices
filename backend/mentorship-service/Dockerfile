# Multi-stage build for Mentorship Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY mentorship-service/pom.xml ./mentorship-service/pom.xml
RUN mvn -f ./mentorship-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY mentorship-service/src ./mentorship-service/src
RUN mvn -f ./mentorship-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/mentorship-service/target/*.jar app.jar
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]
