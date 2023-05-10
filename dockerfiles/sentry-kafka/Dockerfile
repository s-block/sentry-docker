FROM docker.io/bitnami/kafka:3.1-debian-11
USER root
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
USER 1001
