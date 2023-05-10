FROM nginxinc/nginx-unprivileged:1-alpine
# docker run --add-host="172.17.0.2 sentry-web" --add-host="172.17.0.2 sentry-relay" -ti sn
USER root
RUN apk upgrade libxpm
USER 101

EXPOSE 8080

ADD ./server.conf /etc/nginx/conf.d/default.conf
