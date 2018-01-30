#!/bin/bash

#
# This file should be used to prepare and run your WebProxy after setting up your .env file
# Source: https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
#

# Startup NGINX proxy with SSL termination
mkdir -p .proxy
cd .proxy
git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion.git .
rm -Rf .git .github .gitignore nginx.tmpl
cp ../jenky.proxied.env .env
./start.sh

cd ..

# Jenkins prep
echo "JENKINS_SLAVE_SSH_PUBKEY="`cat ~/.ssh/jenky_rsa.pub` > slave.env

## Concourse web and worker prep
mkdir -p keys/web keys/worker

ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

if [ -e hosts.env ]; then
    source hosts.env
else 
    echo "Please set up your hosts.env file before starting your environment."
    exit 1
fi

docker-compose -f docker-compose-proxied.yml build
docker-compose -f docker-compose-proxied.yml up -d

exit 0
