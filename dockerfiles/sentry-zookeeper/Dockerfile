FROM docker.io/bitnami/zookeeper:3.8-debian-11
USER root
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives \
USER 1001
