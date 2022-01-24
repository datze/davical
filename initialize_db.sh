#!/usr/bin/env bash

#CHECK IF THE DAVICAL DATABASE EXISTS, OTHERWISE INITIALIZE IT
echo "postgres:5432:*:davical_dba:${DAVICAL_DBA_PASSWORD}" > ~/.pgpass
chmod 600 ~/.pgpass

INITIALIZED_DB=$(psql -U davical_dba -h postgres -p 5432 -d template1  -c "\l" | grep -c davical)
if [[ $INITIALIZED_DB == 0 ]]; then
/usr/share/davical/dba/create-database.sh davical ${ADMIN_PASSWORD}
fi
unset INITIALIZED_DB

#UPDATE ALWAYS THE DATABASE
/usr/share/davical/dba/update-davical-database ${DBAOPTS} --dbhost postgres --dbuser "${DAVICAL_DBA_USER}" --dbname "davical" --appuser "${DAVICAL_APP_USER}" 

