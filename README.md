# Sentry self-hosted helm and docker container
Sentry helm chart and docker images for running in HO Kubernetes and also includes Sentry self-hosted in Docker container

# Helm chart
https://github.com/sentry-kubernetes/charts

# Images
The following images are built via quay

- quay.io/s_block/busybox
- quay.io/s_block/netcat
- quay.io/s_block/sentry-zookeeper
- quay.io/s_block/sentry-kafka
- quay.io/s_block/sentry-nginx
- quay.io/s_block/sentry-redis
- quay.io/s_block/clickhouse-server
- quay.io/s_block/sentry-relay
- quay.io/s_block/sentry-sentry
- quay.io/s_block/sentry-snuba
- quay.io/s_block/sentry-symbolicator

## Install Helm
```shell script
brew install helm
```

## ENV vars
| name           | type | default | description                                          |
|----------------| ---- | ------- |------------------------------------------------------|
| KUBE_NAMESPACE | str | "" | Currently "default"                                  |
| USER_EMAIL     | str | "" | Email for root user created on first deploy          |
| USER_PASSWORD  | str | "" | Password for root user created on first deploy       |
| GITHUB_SHA     | str | "" | Image tage you want to deploy for all images         |
| REDIS_HOST     | str | "" | HOST of redis used by sentry                         |
| DB_HOST        | str | "" | DB Host                                              |
| DB_USER        | str | "" | DB user                                              |
| DB_NAME        | str | "" | DB name                                              |
| DB_SECRET_NAME | str | "" | Name of kubernetes secret where database password is |
| DE_SECRET_KEY  | str | "" | Name of ke in secret for password                    |

## Deployment
### Deploy manually to kubernetes cluster
Set your kubernetes context to the kube cluster you want to deploy to
```shell script
kubectl config use-context {kube-config}
```
Set environment variables
```shell script
export REDIS_HOST={redis-host}
export DB_USER={db-user}
export DB_NAME={db-name}
export DB_HOST={db-host}
export DB_SECRET_NAME={db-secret-name}
export DB_SECRET_KEY={db-secret-key}
export USER_EMAIL={root-user-email}
export USER_PASSWORD={root-user-password}
export GITHUB_SHA={image-tag}
export WHITELIST_RANGES=0.0.0.0/0,255.255.255.255/2
export APP_HOST=sentry.s-block.com
```

## Deploy using helm
```shell script
cd helm
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm install sentry sentry/sentry \
  --values values.yaml \
  --namespace $KUBE_NAMESPACE \
  --set asHook=true \
  --set user.email=$USER_EMAIL \
  --set user.password=$USER_PASSWORD \
  --set externalRedis.host=$REDIS_HOST \
  --set externalPostgresql.host=$DB_HOST \
  --set externalPostgresql.username=$DB_USER \
  --set externalPostgresql.database=$DB_NAME \
  --set externalPostgresql.existingSecret=$DB_SECRET_NAME \
  --set externalPostgresql.existingSecretKey=$DB_SECRET_KEY \
  --set images.sentry.tag=$GITHUB_SHA \
  --set images.snuba.tag=$GITHUB_SHA \
  --set images.relay.tag=$GITHUB_SHA \
  --set images.symbolicator.tag=$GITHUB_SHA \
  --set hooks.dbCheck.image.tag=$GITHUB_SHA \
  --set nginx.image.tag=$GITHUB_SHA \
  --set redis.image.tag=$GITHUB_SHA \
  --set clickhouse.clickhouse.imageVersion=$GITHUB_SHA \
  --set clickhouse.clickhouse.init.imageVersion=$GITHUB_SHA \
  --set zookeeper.image.tag=$GITHUB_SHA \
  --set kafka.image.tag=$GITHUB_SHA \
  --set kafka.zookeeper.image.tag=$GITHUB_SHA \
  --set "ingress.annotations.ingress\.kubernetes\.io/whitelist-source-range=$(echo ${WHITELIST_RANGES//,/\\\,})" \
  --set "ingress.hostname=$APP_HOST" \
  --set "ingress.tls[0].hosts[0]=$APP_HOST" \
  --kube-insecure-skip-tls-verify \
  --debug \
  --dry-run
```
Remove `--dry-run` to actually deploy

Deploy UPDATE using helm
```shell script
cd helm
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm upgrade sentry sentry/sentry \
  --values values.yaml \
  --namespace $KUBE_NAMESPACE \
  --set asHook=false \
  --set user.email=$USER_EMAIL \
  --set user.password=$USER_PASSWORD \
  --set externalRedis.host=$REDIS_HOST \
  --set externalPostgresql.host=$DB_HOST \
  --set externalPostgresql.username=$DB_USER \
  --set externalPostgresql.database=$DB_NAME \
  --set externalPostgresql.existingSecret=$DB_SECRET_NAME \
  --set externalPostgresql.existingSecretKey=$DB_SECRET_KEY \
  --set images.sentry.tag=$GITHUB_SHA \
  --set images.snuba.tag=$GITHUB_SHA \
  --set images.relay.tag=$GITHUB_SHA \
  --set images.symbolicator.tag=$GITHUB_SHA \
  --set hooks.dbCheck.image.tag=$GITHUB_SHA \
  --set nginx.image.tag=$GITHUB_SHA \
  --set clickhouse.clickhouse.imageVersion=$GITHUB_SHA \
  --set clickhouse.clickhouse.init.imageVersion=$GITHUB_SHA \
  --set zookeeper.image.tag=$GITHUB_SHA \
  --set kafka.image.tag=$GITHUB_SHA \
  --set kafka.zookeeper.image.tag=$GITHUB_SHA \
  --set "ingress.annotations.ingress\.kubernetes\.io/whitelist-source-range=$(echo ${WHITELIST_RANGES//,/\\\,})" \
  --set "ingress.hostname=$APP_HOST" \
  --set "ingress.tls[0].hosts[0]=$APP_HOST" \
  --kube-insecure-skip-tls-verify \
  --debug \
  --dry-run
```

Remove `--dry-run` to actually deploy

### Access Sentry in kubernetes
Currently, if there is no ingres we port forward in kubernetes to the pod
```shell script
kubectl port-forward deployments/sentry-nginx 8080
```
Sentry can now be accessed via http://localhost:8080

### Online Sentry docs
https://sentry.io/

### Slack webhooks
There is a simple webhook proxy that is deployed in drone
```
sentry/webhooks
```
This contains a small webserver that is run in kubernetes and is used for Sentry to send Alerts to. Alerts are then
organised and sent to Slack.

# Sentry in Docker
## Build:
======
Add `# syntax=docker/dockerfile:1.3-labs` to top of dockerfile
Update Dockerfile run command from
```dockerfile
RUN somecommand
```
to
```dockerfile
RUN --security=insecure somecommand
```
Set up builder:
```bash
docker buildx create --driver-opt image=moby/buildkit:master \
    --use --name insecure-builder \
    --buildkitd-flags '--allow-insecure-entitlement security.insecure --allow-insecure-entitlement network.host'
docker buildx use insecure-builder
```
Build:
```bash
docker buildx build --allow security.insecure --allow network.host --load -t sentry .
```
Remove builder:
```bash
docker buildx rm insecure-builder
```
Push image to quay:
===================
```bash
docker tag sentry quay.io/s_block/sentry:latest
docker push quay.io/s_block/sentry
```

Run:
====
```bash
docker run --privileged --name sentry -e DOCKER_HOST=unix:///run/user/1000/docker.sock -p 9000:9000 -ti sentry
```

Create user:
============
exec in to the container and run:
```bash
docker-compose run --rm web createuser
```
