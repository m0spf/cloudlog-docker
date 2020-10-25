#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo ""
echo "*** Taking backup"
echo ""
$DIR/backup.sh

echo ""
echo "*** Updating containers"
echo ""
docker-compose pull
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "*** Updating cloudlog software"
echo ""
cd $DIR/data/cloudlog/
git pull
echo "*** Cloudlog software and container images have been updated."
