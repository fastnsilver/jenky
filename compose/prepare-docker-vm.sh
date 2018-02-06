#!/bin/sh

# Prepares a Linux Ubuntu 16.04 LTS VM with Docker and Docker Compose
# @see https://docs.docker.com/install/linux/docker-ce/ubuntu/#docker-ee-customers
# @see https://docs.docker.com/install/linux/linux-postinstall/
# @see https://docs.docker.com/compose/install/

sudo apt-get remove docker docker-engine docker.io

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce

sudo usermod -aG docker $USER

sudo systemctl enable docker


sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
