#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE davical_dba CREATEDB LOGIN password '${DAVICAL_DBA_PASSWORD}' ;
    CREATE ROLE davical_app LOGIN password '${DAVICAL_APP_PASSWORD}';
EOSQL
