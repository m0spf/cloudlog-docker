#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root, eg sudo ./install.sh"
  exit
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
chown -R 5001:5001 $DIR/data/cloudlog
chmod -R 755 $DIR/data/cloudlog
docker-compose up -d
echo ""
echo "*** To stop run ./stop.sh"
echo "*** To patch and update the containers and cloudlog software run ./update.sh"
echo ""
echo "*** If starting for the first time it make take a few minutes to initalise during which"
echo "*** time you might get database and https errors, keep refreshing"

