#!/usr/bin/env bash
set -eu -o pipefail

echo "JENKINS_SLAVE_SSH_PUBKEY="`cat ~/.ssh/jenky_rsa.pub` > slave.env

docker-compose build
docker-compose -f docker-compose-with-artifactory.yml up -d
