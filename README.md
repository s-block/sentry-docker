# sentry-docker
Sentry self-hosted in Docker container

Build:
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
