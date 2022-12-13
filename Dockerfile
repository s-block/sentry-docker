# syntax=docker/dockerfile:1.3-labs
FROM docker:dind-rootless

ARG SENTRY_VERSION=22.11.0

USER root
RUN apk add bash
RUN mkdir /sentry
WORKDIR /sentry
RUN wget https://github.com/getsentry/self-hosted/archive/refs/tags/${SENTRY_VERSION}.tar.gz
RUN tar -xvzf ${SENTRY_VERSION}.tar.gz
RUN rm ${SENTRY_VERSION}.tar.gz

WORKDIR /sentry/self-hosted-${SENTRY_VERSION}

ADD sentry/sentry_install.sh /sentry/self-hosted-${SENTRY_VERSION}/sentry_install.sh
RUN ["chmod", "+x", "./sentry_install.sh"]
RUN chown -R rootless /sentry
USER rootless
RUN --security=insecure ./sentry_install.sh

USER root
ADD sentry/sentry_entrypoint.sh /sentry/self-hosted-${SENTRY_VERSION}/sentry_entrypoint.sh
RUN ["chmod", "+x", "./sentry_entrypoint.sh"]
RUN chown -R rootless /sentry
USER rootless
EXPOSE 9000
CMD ["sh", "/sentry/self-hosted-${SENTRY_VERSION}/sentry_entrypoint.sh"]
