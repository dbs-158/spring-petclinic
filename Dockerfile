FROM maven:3.9.7-eclipse-temurin-17 AS build
RUN git clone https://github.com/spring-projects/spring-petclinic.git
RUN cd spring-petclinic && mvn clean package


FROM amazoncorretto:17-alpine-jdk
LABEL author="dineshkumar"
LABEL purpose="project"
ARG USER="devuser"
ARG GROUP="dev"
ARG WORKDIR="/spc"
ARG SOURCE="/spring-petclinic/target/spring-petclinic-3.4.0-SNAPSHOT.jar"
ARG DEST="/spc/spring-petclinic.jar"
# Create a new user and group
RUN addgroup -S ${GROUP} && adduser -S ${USER} -G ${GROUP}
USER ${USER}
WORKDIR ${WORKDIR}
COPY --from=build --chown=${USER}:${GROUP} ${SOURCE} ${DEST}
EXPOSE 8080
CMD ["java", "-jar", "spring-petclinic.jar"]