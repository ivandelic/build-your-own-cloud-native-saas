FROM maven:3.8.4-openjdk-11-slim as build
WORKDIR /build
ADD ./src ./src
ADD pom.xml .
RUN mvn package -DskipTests

FROM openjdk:11
WORKDIR /run
COPY --from=build ./build/target/departments-backend-0.0.1-SNAPSHOT.jar .
CMD ["java", "-jar", "-Djdk.tls.client.protocols=TLSv1.2", "departments-backend-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080