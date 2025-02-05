FROM openjdk:17
COPY ./target/*jar medicure.jar
ENTRYPOINT ["java","-jar","/medicure.jar"]
