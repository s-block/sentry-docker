FROM alpine as BUILD
RUN apk add --no-cache netcat-openbsd
RUN adduser -D -H 1000
USER 1000
ENTRYPOINT [ "nc" ]
