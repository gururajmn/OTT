# ---------- Stage 1: Build ----------
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:21-jre

WORKDIR /app

RUN groupadd -r ottapp && useradd -r -g ottapp ottapp

COPY --from=build /app/target/ott-platform.jar app.jar

RUN chown -R ottapp:ottapp /app

USER ottapp

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
CMD wget -qO- http://localhost:8081/api/ping || exit 1

ENTRYPOINT ["java","-jar","app.jar"]
