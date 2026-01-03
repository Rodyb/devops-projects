FROM maven:3.9.9-eclipse-temurin-17

WORKDIR /tests

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src

ENV BASE_URL=http://messageboard-app:5000 \
    DB_URL=jdbc:postgresql://messageboard-db:5432/messageboard \
    DB_USER=messageboard \
    DB_PASS=messageboard_password

CMD ["mvn", "-B", "test"]
