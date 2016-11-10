#!/bin/sh

ORACLE_SID=SEAP
ORAENV_ASK=NO . oraenv
SYS_PWD=''

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
			select dblink from arm_admin.arm_databases where transfer_enabled = 'Y' and version like '1%' and DBLINK != 'PA0' order by 1;
			exit;
		EOF
	fi
}

#
# attempt to login as sys into a remote DB using specified TNS alias
#
runSQL() {
#	cat <<-EOF
	sqlplus -s /nolog <<-EOF
		whenever oserror exit failure
		whenever sqlerror exit failure
		conn SYSTEM/${SYS_PWD}@$1

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
	if runSQL $TNSALIAS  | tee -a fra_space.log; then
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
