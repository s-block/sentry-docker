#!/usr/bin/env bash
set -eE

nohup dockerd-entrypoint.sh &>/dev/null &

sleep 20

export DOCKER_HOST=unix:///run/user/1000/docker.sock

./install.sh --no-report-self-hosted-issues --skip-user-creation

rootlessid=$(ps aux | grep rootlesskit | grep -v grep | awk '{print $1}' | xargs)
while [[ ! -z "$rootlessid" ]]; do
    echo "Killing...-$rootlessid-"
    kill $rootlessid
    sleep 1
    rootlessid=$(ps aux | grep rootlesskit | grep -v grep | awk '{print $1}' | xargs)
done
