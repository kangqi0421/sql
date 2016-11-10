#!/bin/bash

{ rman <<ERMAN
set echo on;

connect target /;

configure controlfile autobackup format for device type 'SBT_TAPE' clear;
configure controlfile autobackup format for device type disk clear;
configure device type 'SBT_TAPE' clear;
configure device type disk clear;
configure datafile backup copies for device type 'SBT_TAPE' clear;
configure datafile backup copies for device type disk clear;
configure archivelog backup copies for device type 'SBT_TAPE' clear;
configure archivelog backup copies for device type disk clear;
configure maxsetsize clear;
configure encryption for database clear;
configure encryption algorithm clear;
configure compression algorithm clear;
configure archivelog deletion policy clear;
configure snapshot controlfile name clear;

configure retention policy to recovery window of 7 days;
configure backup optimization on;
configure default device type to 'SBT_TAPE';
configure controlfile autobackup on;
configure device type 'SBT_TAPE' parallelism 2 backup type to backupset;
configure channel device type 'sbt_tape'
  parms 'SBT_LIBRARY=/opt/tivoli/tsm/client/oracle/bin64/libobk.so,ENV=(TDPO_OPTFILE=/dba/rman/tdpo/${ORACLE_SID%%[12]}_tdpo.opt)'
  maxpiecesize 16g format '%d-%I-%T-%U';

show all;

sql "alter database enable block change tracking";

backup current controlfile;
ERMAN
} 2>&1 | tee configure.rman.$ORACLE_SID.log
