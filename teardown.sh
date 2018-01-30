#!/bin/bash

# CAUTION: Executing this script is a destructive operation. 
# Will stop all running containers then remove all unused container images, volumes and networks.

read -n1 -r -p "This script will stop all running containers then remove all unused container images, volumes and networks. Do you wish to continue? [y/n]" key

if [ "$key" = 'y' ] || [ "$key" = 'Y' ]; then
    docker stop $(docker ps -a -q)
    docker system prune -a -f
    sudo rm /tmp/nginx
    sudo rm -Rf .proxy
    mkdir .proxy
    rm slave.env
    printf "\nCompleted operation.\n"
else
    printf "\nCanceled operation.\n"
fi

exit 0
