#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/.env

if ! type "git" > /dev/null; then
	echo "ERROR: please install git"
	exit 1
fi

echo ""
echo "*** WARNING - this will erase all existing data (apart from backups), if you just want to update then run ./update.sh"
echo ""
read -r -p " Are you sure you want to proceed? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
	echo "Exiting..."
        exit 1
        ;;
esac

if [ -f $DIR/data ]; then
  echo ""
  echo "*** data directory exists, taking backup just in case..."
  echo ""
  $DIR/backup.sh
fi

echo ""
echo "*** Removing docker containers in case they are still running"
echo ""
docker-compose down

echo ""
echo "*** Removing any existing data that might exist (not backups)"
echo ""
rm -rf $DIR/data/db
rm -rf $DIR/data/cloudlog
rm -rf $DIR/data/certs
rm -rf $DIR/data/conf.d
rm -rf $DIR/data/html
rm -rf $DIR/data/vhost.d

echo ""
echo "*** Creating directories and cloning cloudlog repo from git"
echo ""
mkdir -p $DIR/data/cloudlog
mkdir -p $DIR/data/backup/auto
git clone https://github.com/magicbug/Cloudlog.git $DIR/data/cloudlog/

echo ""
echo "*** Creating config.php and database.php configs"
echo ""
CONFIGFILE=/data/cloudlog/application/config/config.php
SAMPLE_CONFIGFILE=/data/cloudlog/application/config/config.sample.php
DBCONFIGFILE=/data/cloudlog/application/config/database.php
SAMPLE_DBCONFIGFILE=/data/cloudlog/application/config/database.sample.php
if [ -f $DIR/${SAMPLE_CONFIGFILE} ]; then
    # Copy template
    cp $DIR/${SAMPLE_CONFIGFILE} $DIR/${CONFIGFILE}

    # Update config
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['base_url'\] = '([^\']*)+'\;|\['base_url'\] = '${BASE_URL:-http://localhost/}'\;|g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['directory'\] = '([^\']*)+'\;|\['directory'\] = '${WEB_DIRECOTRY}'\;|g" ${CONFIGFILE}

    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['callbook'\] = \"([^\']*)+\"\;/\['callbook'\] = \"${CALLBOOK:-hamqth}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['hamqth_username'\] = \"([^\']*)+\"\;/\['hamqth_username'\] = \"${HAMQTH_USERNAME//\//\\/}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['hamqth_password'\] = \"([^\']*)+\"\;/\['hamqth_password'\] = \"${HAMQTH_PASWORD//\//\\/}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['qrz_username'\] = \"([^\']*)+\"\;/\['qrz_username'\] = \"${QRZ_USERNAME//\//\\/}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['qrz_password'\] = \"([^\']*)+\"\;/\['qrz_password'\] = \"${QRZ_PASSWORD//\//\\/}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['locator'\] = \"([^\']*)+\"\;/\['locator'\] = \"${LOCATOR//\//\\/}\"\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/\['display_freq'\] = ([^\']*)+\;/\['display_freq'\] = ${DISPLAY_FREQ//\//\\/}\;/g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['sess_driver'\] = '([^\']*)+'\;|\['sess_driver'\] = '${SESSION_DRIVER:-files}'\;|g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['sess_save_path'\] = '([^\']*)+'\;|\['sess_save_path'\] = '${SESSION_SAVE_PATH:-/tmp}'\;|g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['sess_expiration'\] = '([^\']*)+'\;|\['sess_expiration'\] = '${SESSION_EXPIRATION:-0}'\;|g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['index_page'\] = 'index.php'\;|\['index_page'\] = ''\;|g" ${CONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s|\['proxy_ips'\] = '([^\']*)+'\;|\['proxy_ips'\] = '${PROXY_IPS:-10.0.0.0/8}'\;|g" ${CONFIGFILE}
    echo ""
    echo "*** config.php file has been created."
    echo ""
else
    echo ""
    echo "*** No config template found.. can't install"
    echo ""
    exit 1
fi
if [ -f $DIR/${SAMPLE_DBCONFIGFILE} ]; then

    # Copy template
    cp $DIR/${SAMPLE_DBCONFIGFILE} $DIR/${DBCONFIGFILE}

    # Update config for custom mysql
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/'hostname' => '([^\']*)+',/'hostname' => 'db',/g" ${DBCONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/'username' => '([^\']*)+',/'username' => '${MYSQL_USER}',/g" ${DBCONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/'password' => '([^\']*)+',/'password' => '${MYSQL_PASSWORD//\//\\/}',/g" ${DBCONFIGFILE}
    docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -ri "s/'database' => '([^\']*)+',/'database' => '${MYSQL_DATABASE}',/g" ${DBCONFIGFILE}
    echo ""
    echo "*** database.php config file has been created."
    echo ""

else
    echo ""
    echo "*** No DB config template found.. can't install"
    echo ""
    exit 1
fi

echo ""
echo "*** Creating cron file"
echo ""
mkdir -p $DIR/data/cron.d
echo "SHELL=/bin/bash" > $DIR/data/cron.d/cloudlog
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin" >> $DIR/data/cron.d/cloudlog
echo "@daily cloudlog curl --silent http://${APP_NAME}_web:8080/index.php/lotw/load_users &>/dev/null" >> $DIR/data/cron.d/cloudlog
echo "@daily cloudlog curl --silent http://${APP_NAME}_web:8080/index.php/update/update_clublog_scp &>/dev/null" >> $DIR/data/cron.d/cloudlog
echo "@daily cloudlog curl --silent http://${APP_NAME}_web:8080/index.php/update/dxcc &>/dev/null" >> $DIR/data/cron.d/cloudlog

# Generate random offset for the crons so that the servers dont get hit on the hour/minute
OFFSET=$(docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm shuf -i5-55 -n1)
OFFSET_TRIMMED=$(echo $OFFSET | tr -dc '0-9')
if [ "${CLUBLOG_UPLOAD_CRON}" == true ]; then
    echo "$OFFSET_TRIMMED * * * * cloudlog sleep $OFFSET_TRIMMED; curl --silent http://${APP_NAME}_web:8080/index.php/clublog/upload/${CALLSIGN} &>/dev/null" >> $DIR/data/cron.d/cloudlog
fi
if [ "${LOTW_UPLOAD_CRON}" == true ]; then
    echo "$OFFSET_TRIMMED * * * * cloudlog sleep $OFFSET_TRIMMED; curl --silent http://${APP_NAME}_web:8080/lotw/lotw_upload &>/dev/null" >> $DIR/data/cron.d/cloudlog
fi
if [ "${AUTO_BACKUPS}" == true ]; then
echo "@daily cloudlog cron-backup.sh" >> $DIR/data/cron.d/cloudlog
fi

echo ""
echo "*** Generating self signed cert for local access or in case of letsencrypt issues"
echo ""
mkdir -p $DIR/data/certs
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/CN=${APP_HOSTNAME}" -keyout $DIR/data/certs/${APP_HOSTNAME}.key -out $DIR/data/certs/${APP_HOSTNAME}.crt

echo ""
echo "*** Backup page"
echo ""
echo "This feature is disabled as no security is implemented." > $DIR/data/cloudlog/backup/index.html
echo " To backup log use the ADIF export menu, or collect raw SQL backups from ./data/backup/ on the server filesystem" >> $DIR/data/cloudlog/backup/index.html

echo ""
echo "*** Copying .htaccess file"
echo ""
#cp $DIR/data/cloudlog/.htaccess.sample $DIR/data/cloudlog/.htaccess

echo ""
echo "*** Copying DB install.sql to mysql initdb.d dir"
echo ""
mkdir -p $DIR/data/initdb.d
cp $DIR/data/cloudlog/install/assets/install.sql $DIR/data/initdb.d/

echo ""
echo "*** Creating cloudlog user"
echo ""

HASHED_PW=$(docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm php -r 'echo password_hash("'"${CLOUDLOG_PASSWORD}"'", PASSWORD_DEFAULT);')
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm sed -i "/m0abc/c INSERT INTO \`users\` VALUES ('4','${CLOUDLOG_USERNAME}','${HASHED_PW}','${EMAIL}','99','${CALLSIGN}','${LOCATOR}','${FIRST_NAME}','${LAST_NAME}','151',null,null,null,null,null);" /data/initdb.d/install.sql

echo ""
echo "*** Removing Cloudlog install dir"
echo ""
rm -rf $DIR/data/cloudlog/install/

echo ""
echo "*** Setting permissions"
echo ""
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm chown -R 5001:5001 /data/cloudlog
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm chmod -R 755 /data/cloudlog
docker run -it --name install_worker --mount type=bind,source=$DIR/data/,target=/data --rm php:7-fpm chown -R 5001:5001 $DIR/data/backup/auto

echo ""
echo "*** Pulling images and building containers"
echo ""
docker-compose pull
docker-compose build

echo ""
echo "*** Install complete, if you are wanting to restore from a sql database backup then place the backup .sql or sql.gz file in ./data/initdb.d and remove install.sql before you run start.sh"
echo ""

read -r -p "Start now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
	$DIR/start.sh
	exit 0
        ;;
    *)
        echo "Exiting..."
        exit 1
        ;;
esac
echo ""
echo ""
