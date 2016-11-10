#!/bin/bash

ORACLE_SID=OMST
ORAENV_ASK=NO . oraenv

SYS_PWD=''
LOG=/var/log/dba/`date +%Y%m%d_%H%M%S`_`basename $0`.log

#
# nastaveni terminalu pri ukonceni skriptu
#
cleanup () {
	stty echo
	exit
}

#
# Determine how to suppress newline with echo command.
#
SetEcho () {
  N=
  C=
  if echo "\c" | grep c >/dev/null 2>&1; then
      N='-n'
  else
      C='\c'
fi

}

#
# Echo with suppressed new line.
#
echonnl () {
  echo $N "$@ $C"
}

#
# get list of target DB links supposed to be working
#
getDBLinks() {
	if [ $# -gt 0 ]; then
		while [ $# -gt 0 ]; do
			echo ${1}
			shift
		done
	else
		sqlplus -s <<-EOF | grep -v "^[[:space:]]*$"
			/ as sysdba
			set echo off feed off hea off pages 9999 trims on lines 32767
SELECT    -- tnsnames 
         '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST='
         || HOST.property_value
         || ')(PORT='
         || port.property_value
         || ')))(CONNECT_DATA=(SID='
         || sid.property_value
         || ')(SERVER=DEDICATED)))'
            tns
    FROM mgmt_targets tn,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'MachineName') HOST,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'Port') port,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'SID') sid
   WHERE     tn.target_guid = HOST.target_guid
         AND tn.target_guid = port.target_guid
         AND tn.target_guid = sid.target_guid
         AND tn.target_type IN ('oracle_database', 'rac_database')
         AND tn.category_prop_3 = 'DB'
         --AND tn.target_name = 'WCMT'
         --AND tn.target_guid IN (SELECT TARGET_GUID FROM SYSMAN.MGMT\$GROUP_MEMBERS WHERE group_name = 'all_databases')
ORDER BY 1;
			exit;
		EOF
	fi
}

#
# attempt to login as sys into a remote DB using specified TNS alias
#
runSQL() {
	echo TNS: $1
	sqlplus -s /nolog <<-EOF
		whenever oserror exit failure
		whenever sqlerror exit failure
		conn system/${SYS_PWD}@$1

SELECT sys_context('USERENV', 'SESSION_USER')||'@'||sys_context('USERENV', 'INSTANCE_NAME') "connect id:" FROM DUAL;

		@change_profile.sql
		exit;
	EOF
}

appendOK() {
	echo $LIST_OK
	echo $*
}

appendERR() {
	echo $LIST_ERR
	echo $*
}

trap cleanup SIGHUP SIGINT SIGTERM

SetEcho 
# prompt for SYSTEM user password
while [ -z "$SYS_PWD" ]
  do
    echonnl "SYSTEM user password: " >&2
    stty -echo; read; stty echo; echo >&2
    export SYS_PWD="$REPLY"
  done

getDBLinks $* | while read TNSALIAS; do
	if runSQL $TNSALIAS  | tee -a $LOG ; then
		LIST_OK=`appendOK $TNSALIAS`
	else
		LIST_ERR=`appendERR $TNSALIAS`
	fi
done

echo
echo Working connections:
echo $LIST_OK

echo Failed connections:
echo $LIST_ERR
echo
