#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/.env
DATE=$(date +%Y%m%d%H%M)
mkdir -p $DIR/data/backup

echo "*** WARNING - for SQL backup to work db container must be running"

docker container exec ${APP_NAME}_db bash -c 'echo "[client]" > /root/mysql.cnf'
docker container exec ${APP_NAME}_db bash -c 'echo "user = root" >> /root/mysql.cnf'
docker container exec ${APP_NAME}_db bash -c 'echo "password = $MYSQL_ROOT_PASSWORD" >> /root/mysql.cnf'
docker container exec ${APP_NAME}_db bash -c 'echo "host = localhost" >> /root/mysql.cnf'
docker container exec ${APP_NAME}_db bash -c 'chmod 600 /root/mysql.cnf'

# Backup database
docker container exec ${APP_NAME}_db bash -c 'mysqldump --defaults-extra-file=/root/mysql.cnf --single-transaction --routines --triggers $MYSQL_DATABASE |gzip -9 > /backup/'${MYSQL_DATABASE}'_manual.'$DATE'.sql.gz'

# Backup cloudlog files
cd $DIR/data/cloudlog
tar zcf $DIR/data/backup/cloudlog-files_manual.$DATE.tar.gz .

echo ""
echo "*** Script complete """
echo ""
