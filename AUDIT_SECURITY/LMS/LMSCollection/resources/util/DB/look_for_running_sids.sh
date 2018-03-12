#!/bin/sh
. ./helper_functions.sh
#setAlias

OS_NAME=`uname -s`
MACHINE_NAME=`uname -n`
sql_script=$1

$ECHO CONNECTION_METHOD,ORACLE_HOME_SERVER,ORACLE_SID,OS_USER,TNS_NAME,TNS_HOST,TNS_PORT,TNS_SERVICE_NAME,TNS_SID,DB_USER,SQL,MACHINE_NAME >db_list.csv

#count=0

echo "#ps -ef | grep ora_pmon_ | grep -v grep" >look_for_running_sids.log
ps -ef | grep ora_pmon_ | grep -v grep >>look_for_running_sids.log

PMONPIDS=`ps -ef | grep ora_pmon_ | grep -v 'grep ora_pmon_' | awk '{print $2}'`

	for PID in $PMONPIDS
	do
	ORACLE_SID_PMON=`ps -ef | grep ora_pmon_ | grep -w $PID | sed 's/^.*ora_pmon_//g' | sed 's/ //g'`
	OS_USER=`ps -ef | grep ora_pmon_ | grep -w $PID | awk '{print $1}'`
	
	if [ "$OS_NAME" = "SunOS" ] ; then
		echo "#/usr/bin/pwdx $PID 2>/dev/null" >>look_for_running_sids.log
		/usr/bin/pwdx $PID 2>/dev/null >>look_for_running_sids.log
		echo "#/usr/bin/pargs -e $PID 2>/dev/null" >>look_for_running_sids.log
		/usr/bin/pargs -e $PID 2>/dev/null | egrep 'ORACLE_|LD_LIBRARY_PATH' >>look_for_running_sids.log	
		ORACLE_HOME_WD=`/usr/bin/pwdx $PID 2>/dev/null | cut -d':' -f2 | sed -e 's/\/dbs//g' -e 's/	//g' -e 's/ //g' | awk '{print $1}'`
		ORACLE_HOME_ENV=`/usr/bin/pargs -e $PID 2>/dev/null | grep ' ORACLE_HOME=' | cut -d'=' -f2 | awk '{print $1}'`
		ORACLE_SID_ENV=`/usr/bin/pargs -e $PID 2>/dev/null | grep ' ORACLE_SID=' | cut -d'=' -f2`
	elif [ "$OS_NAME" = "AIX" ] ; then
		echo "#ls -l /proc/$PID/cwd 2>/dev/null" >>look_for_running_sids.log
		ls -l /proc/$PID/cwd 2>/dev/null >>look_for_running_sids.log
		echo "#ps eauwww $PID 2>/dev/null" >>look_for_running_sids.log
		ps eauwww $PID 2>/dev/null |  tr ' ' '\012' | egrep 'ORACLE_|LD_LIBRARY_PATH' >>look_for_running_sids.log
		ORACLE_HOME_WD=`ls -l /proc/$PID/cwd 2>/dev/null | grep '>' | cut -d'>' -f2 | sed -e 's/\/dbs\///g' -e 's/ //g' | awk '{print $1}'`
		ORACLE_HOME_ENV=`ps eauwww $PID 2>/dev/null |  tr ' ' '\012' | grep '^ORACLE_HOME=' | cut -d'=' -f2 | awk '{print $1}'`
		ORACLE_SID_ENV=`ps eauwww $PID 2>/dev/null |  tr ' ' '\012' | grep '^ORACLE_SID=' | cut -d'=' -f2`
	elif [ "$OS_NAME" = "Linux" ] ; then
		echo "#/usr/bin/pwdx $PID 2>/dev/null" >>look_for_running_sids.log
		/usr/bin/pwdx $PID 2>/dev/null >>look_for_running_sids.log
		echo "#/usr/bin/strings /proc/$PID/environ 2>/dev/null" >>look_for_running_sids.log
		/usr/bin/strings /proc/$PID/environ 2>/dev/null | egrep 'ORACLE_|LD_LIBRARY_PATH' >>look_for_running_sids.log
		ORACLE_HOME_WD=`/usr/bin/pwdx $PID 2>/dev/null | grep -v denied |  cut -d' ' -f2 | sed -e 's/\/dbs//g' | awk '{print $1}'`
		ORACLE_HOME_ENV=`/usr/bin/strings /proc/$PID/environ 2>/dev/null | grep -v denied | grep '^ORACLE_HOME=' | cut -d'=' -f2 | awk '{print $1}'`
		ORACLE_SID_ENV=`/usr/bin/strings /proc/$PID/environ 2>/dev/null | grep -v denied | grep '^ORACLE_SID=' | cut -d'=' -f2`
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		echo "#/usr/bin/pfiles $PID 2>/dev/null" >>look_for_running_sids.log
		/usr/bin/pfiles $PID 2>/dev/null >>look_for_running_sids.log
		ORACLE_HOME_ENV=`/usr/bin/pfiles $PID 2>/dev/null | grep bin |  cut -d':' -f2 | sed  -e 's/ //g' -e 's/	//g' -e 's/\/bin\/oracle//g' | awk '{print $1}'`
		ORACLE_SID_ENV=$ORACLE_SID_PMON
	fi
#	count=`expr $count + 1`

    if [ "$ORACLE_HOME_ENV" = "" ]; then
	   ORACLE_HOME_ENV=$ORACLE_HOME_WD
	fi
	
	if [ "$ORACLE_SID_ENV" = "" ]; then
	   ORACLE_SID_ENV=$ORACLE_SID_PMON
	fi
	
	if [ "$ORACLE_HOME_ENV" = "" ];then
	  ORACLE_HOME_ENV=UNKNOWN
	else
      $ECHO $ORACLE_HOME_ENV >>oracle_homes_a.txt
	  echo "#ls -l $ORACLE_HOME_ENV/bin/oracle" >>look_for_running_sids.log
	  ls -l $ORACLE_HOME_ENV/bin/oracle >>look_for_running_sids.log
	  OS_USER_ENV=`ls -l $ORACLE_HOME_ENV/bin/oracle | tail -1 | awk '{print $3}'`
	  
	  if [ "$OS_USER_ENV" != "" ] && [ "$OS_USER_ENV" != "$OS_USER" ]; then
		OS_USER=$OS_USER_ENV
	  fi
	  
	  if [ "$OS_NAME" = "SunOS" ] && [ "$OS_USER_ENV" = "" ] && [ "$ORACLE_HOME_WD" != "" ] && [ "$ORACLE_HOME_WD" != "$ORACLE_HOME_ENV" ]; then
		continue
	  fi
	  
	fi  
		
    $ECHO LOCAL,$ORACLE_HOME_ENV,$ORACLE_SID_PMON,$OS_USER,,,,,,,$sql_script,$MACHINE_NAME >>db_list.csv
	
	done

	echo "#cat /etc/oratab" >>look_for_running_sids.log
	cat /etc/oratab 2>/dev/null | egrep -v '^#' | egrep -v '^$' >>look_for_running_sids.log
	
chmod 777 db_list.csv

if [ -f oracle_homes_a.txt ] ; then
	chmod 777 oracle_homes_a.txt
fi  


