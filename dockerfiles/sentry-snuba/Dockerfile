FROM getsentry/snuba:22.10.0
USER root
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
USER snuba
