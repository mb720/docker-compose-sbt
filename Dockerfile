# Our base image: https://hub.docker.com/_/openjdk/
# The JRE is used to start SBT which will download compilers, plugins, and their dependencies
FROM openjdk:8u131-jre-alpine

MAINTAINER Matthias Braun <matthias@bullbytes.com>

# Install curl, bash (needed by SBT), and py-pip which we use to install Docker Compose
RUN apk add --no-cache bash curl py-pip

# Install SBT
ARG sbtVersion=0.13.15
ARG sbtHome=/usr/local/sbt
ENV PATH ${PATH}:${sbtHome}/bin

ARG sbtArchiveUrl=https://github.com/sbt/sbt/releases/download/v$sbtVersion/sbt-$sbtVersion.tgz

RUN mkdir -p "$sbtHome" && curl -L $sbtArchiveUrl | tar xz --strip-components 1 --directory $sbtHome

# Install Docker
ARG docker_channel=edge
# See this for the most recent version: https://github.com/moby/moby/blob/master/CHANGELOG.md
ARG dockerVersion=17.05.0-ce

RUN curl -L "https://download.docker.com/linux/static/${docker_channel}/x86_64/docker-${dockerVersion}.tgz" | tar xz --strip-components 1 --directory /usr/local/bin/

# Install Docker Compose using pip which also installs the required glibc.
# To install without pip, see https://github.com/wernight/docker-compose or https://github.com/ncrmro/docker-and-compose
RUN pip install docker-compose

# Some smoke testing
RUN ["docker-compose", "version"]
RUN ["docker", "-v"]
RUN ["dockerd", "-v"]
RUN ["sbt", "sbtVersion"]

# Remove the dependencies installed with APK safe for bash, which SBT needs
RUN apk del curl py-pip
