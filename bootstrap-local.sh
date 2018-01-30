#!/usr/bin/env bash
set -eu -o pipefail

## Jenkins slave
echo "JENKINS_SLAVE_SSH_PUBKEY="`cat ~/.ssh/jenky_rsa.pub` > slave.env

## Concourse web and worker
mkdir -p keys/web keys/worker

ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

## Build and start-up
docker-compose build
docker-compose up -d
