#!/usr/bin/env bash
set -eu -o pipefail

docker-compose build
docker-compose up -d
