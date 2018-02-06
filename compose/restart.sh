#!/bin/bash

#
# This file should be used to restart your WebProxy
# Source: https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
#

# Startup NGINX proxy with SSL termination
cd .proxy
./start.sh

# Startup Jenky
cd ..

if [ -e hosts.env ]; then
    source hosts.env
else 
    echo "Please set up your hosts.env file before starting your environment."
    exit 1
fi

docker-compose -f docker-compose-proxied.yml build
docker-compose -f docker-compose-proxied.yml up -d

exit 0