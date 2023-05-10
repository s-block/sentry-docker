# FROM clickhouse/clickhouse-server:22.3.17.13-alpine
FROM yandex/clickhouse-server:20.8.19.4

RUN chown -R 101:101 /var/log/clickhouse-server
RUN chown -R 101:101 /var/lib/clickhouse
RUN chmod -R 777 /var/lib/clickhouse

ADD entrypoint.sh /entrypoint.sh
RUN chown -R 101:101 /entrypoint.sh
RUN chmod -R 777 /entrypoint.sh

RUN apt-mark hold clickhouse-client
RUN apt-mark hold clickhouse-server
RUN apt-mark hold clickhouse-common-static

RUN rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

USER clickhouse
