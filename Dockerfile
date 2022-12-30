FROM gcr.io/distroless/java17-debian11
ARG JAR_FILE=target/*.jar
COPY build/libs/helloservice-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]