#!/bin/bash

XWIKI_CONTAINER=$(docker ps -aqf "name=xwiki")
XWIKI_BACKUPS_CONTAINER=$(docker ps -aqf "name=xwiki_backups")

echo "--> All available database backups:"

for entry in $(docker container exec -it $XWIKI_BACKUPS_CONTAINER sh -c "ls /srv/xwiki-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: xwiki-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Stopping service..."
docker stop $XWIKI_CONTAINER

echo "--> Restoring database..."
docker exec -it $XWIKI_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(echo $POSTGRES_PASSWORD)" dropdb -h postgres -p 5432 xwiki -U xwikidbuser \
&& PGPASSWORD="$(echo $POSTGRES_PASSWORD)" createdb -h postgres -p 5432 xwiki -U xwikidbuser \
&& PGPASSWORD="$(echo $POSTGRES_PASSWORD)" gunzip -c /srv/xwiki-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(echo $POSTGRES_PASSWORD) psql -h postgres -p 5432 xwikidb -U xwikidbuser'
echo "--> Database recovery completed..."

echo "--> Starting service..."
docker start $XWIKI_CONTAINER
