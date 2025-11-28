FROM maven:3.6-jdk-8-alpine AS build

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn package -DskipTests

FROM amazoncorretto:8-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8083

CMD ["java", "-jar", "app.jar"]
