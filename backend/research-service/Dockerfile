# Multi-stage build for Research Service
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies layer
COPY pom.xml ./pom.xml
COPY research-service/pom.xml ./research-service/pom.xml
RUN mvn -f ./research-service/pom.xml dependency:go-offline -q

# Copy source code and build
COPY research-service/src ./research-service/src
RUN mvn -f ./research-service/pom.xml clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/research-service/target/*.jar app.jar
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "app.jar"]
