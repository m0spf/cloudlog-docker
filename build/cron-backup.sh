#!/bin/bash

# Backup database
mysqldump --defaults-extra-file=/home/cloudlog/mysql.cnf --single-transaction --routines --triggers {$MYSQL_DATABASE} | gzip -9 > /backup/auto/${MYSQL_DATABASE}-db_auto.$DATE.sql.gz

# Backup cloudlog files
cd /cloudlog
tar zcvf /backup/daily/cloudlog-files_auto.$DATE.tar.gz .

# remove database backups older than 14 days
find /backup/auto -name "*.sql.gz" -type f -mtime +14 -exec rm -f {} \;

# remove cloudlog backups older than 7 days
find /backup/auto -name "*.tar.gz" -type f -mtime +7 -exec rm -f {} \;
