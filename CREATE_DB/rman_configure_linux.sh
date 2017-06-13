#!/bin/bash

{ rman <<ERMAN
set echo on;

connect target /;

sql "begin dbms_backup_restore.resetconfig(); end;";

configure retention policy to recovery window of 7 days;
configure backup optimization on;
configure default device type to 'SBT_TAPE';
configure controlfile autobackup on;
configure device type 'SBT_TAPE' parallelism 2 backup type to backupset;
configure channel device type 'sbt_tape'
  parms 'ENV=(TDPO_OPTFILE=/dba/rman/tdpo/${ORACLE_SID%%[12]}_tdpo.opt)'
  maxpiecesize 64g format '%d-%I-%T-%U';

show all;

sql "alter database enable block change tracking";

backup current controlfile;
ERMAN
} 2>&1 | tee ${ORACLE_SID}_rman_configure.log
