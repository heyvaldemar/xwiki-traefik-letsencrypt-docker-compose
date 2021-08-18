#!/bin/bash

XWIKI_CONTAINER=$(docker ps -aqf "name=xwiki_xwiki")
XWIKI_BACKUPS_CONTAINER=$(docker ps -aqf "name=xwiki_backups")

echo "--> All available application data backups:"

for entry in $(docker container exec -it $XWIKI_BACKUPS_CONTAINER sh -c "ls /srv/xwiki-application-data/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore application data and press [ENTER]
--> Example: xwiki-application-data-backup-YYYY-MM-DD_hh-mm.tar.gz"
echo -n "--> "

read SELECTED_APPLICATION_BACKUP

echo "--> $SELECTED_APPLICATION_BACKUP was selected"

echo "--> Stopping service..."
docker stop $XWIKI_CONTAINER

echo "--> Restoring application data..."
docker exec -it $XWIKI_BACKUPS_CONTAINER sh -c "rm -rf /usr/local/xwiki/* && tar -zxpf /srv/xwiki-application-data/backups/$SELECTED_APPLICATION_BACKUP -C /"
echo "--> Application data recovery completed..."

echo "--> Starting service..."
docker start $XWIKI_CONTAINER