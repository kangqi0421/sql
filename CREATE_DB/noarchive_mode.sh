#!/bin/bash

srvctl stop db -d ${ORACLE_SID%%[1-9]}

sqlplus -s / as sysdba <<ESQL
STARTUP MOUNT
alter database noarchivelog;
SHUTDOWN IMMEDIATE
ESQL

##sudo /usr/symcli/bin/symsnapvx -sid 756 -sg tordb05_tordb06_rtoti_d01 list
##sudo /usr/symcli/bin/symsnapvx -sid 756 -sg tordb05_tordb06_rtoti_d01 -name RTOTI establish

srvctl start db -d ${ORACLE_SID%%[1-9]}
echo "delete noprompt archivelog all;" | rman target=/

