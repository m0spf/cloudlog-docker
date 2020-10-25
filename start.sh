#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo ""
echo "*** Setting permissions, might take a few seconds"
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm chown -R 5001:5001 /data/cloudlog
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm chmod -R 755 /data/cloudlog
docker-compose up -d
echo ""
echo "*** To stop run ./stop.sh"
echo "*** To patch and update the containers and cloudlog software run ./update.sh"
echo ""
echo "*** If starting for the first time it make take a few minutes to initalise during which"
echo "*** time you might get database and https errors, keep refreshing"

