#!/bin/bash

srvctl stop db -d ${ORACLE_SID%%[1-9]}

sqlplus -s / as sysdba <<ESQL
STARTUP MOUNT
alter database noarchivelog;
SHUTDOWN IMMEDIATE
ESQL

srvctl start db -d ${ORACLE_SID%%[1-9]}

echo "delete noprompt archivelog all;" | rman target=/

