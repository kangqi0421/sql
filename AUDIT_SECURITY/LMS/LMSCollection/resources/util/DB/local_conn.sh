#!/bin/sh
. ./helper_functions.sh

get_USR_ID()
{
USER_ID_CMD=`type whoami >/dev/null 2>/dev/null && echo "Found" || echo "NotFound"`

if [ "$USER_ID_CMD" = "Found" ] ; then
	USR_ID=`whoami`
else
	if [ "$OS_NAME" = "SunOS" ] ; then
		if [ -x /usr/ucb/whoami ] ; then
			USR_ID=`/usr/ucb/whoami`
		fi
	else
		USR_ID=$LOGNAME
	fi
fi
}

log_write()
{
 $ECHO  $1 >>$logfile
} 

check_space() {
LMSCT_NOSPACE=0
echo "checking disk space" >checkspace.txt
if [ ! -s checkspace.txt ]; then
	LMSCT_NOSPACE=1
	echo "DB: LMS-02019: ERROR: No disk space available on ${LMSCT_TMP} folder"
	if [ -f checkspace.txt ]; then
		rm -f checkspace.txt
	fi
else 
    rm -f checkspace.txt
fi
}


ask_yn()
{
answ=""
while [ "$answ" = "" ]
do
  $ECHO "$question (y/n)? : "; read answ
done
if [ "$answ" = "y" -o "$answ" = "Y" ]; then 
	yn="y";
else
	if [ "$answ" = "n" -o "$answ" = "N" ]; then
		yn="n";
	else
		ask_yn;
	fi
fi
}


check_sqlplus()
{
  if [ -f $V_ORACLE_HOME/bin/sqlplus  -a -x $V_ORACLE_HOME/bin/sqlplus ];then
  # 	sqlplus_vers=`echo exit | $V_ORACLE_HOME/bin/sqlplus /nolog | grep "Release" | sed  -e 's/SQL\*Plus: Release //g' | cut -d'.' -f1`
	    con_string="/ as sysdba"
		chksqlp=0  
  else
	$ECHO "sqlplus executable was not found in $V_ORACLE_HOME/bin"
	chksqlp=1
  fi
}

check_oracle_home()
{
if [ "$V_ORACLE_HOME" = "" ]; then
#	if [ "$chksqlp" = "" ]; then	
#	  $ECHO "Unable to find the value for ORACLE_HOME"
#	fi  
	
	answer=""
	while [ "$answer" = "" ] && [ "$LICAGREE" != "YES" ]
	do
	 $ECHO "Enter a valid ORACLE_HOME location for the SQL*Plus client to be used"; read answer
	 V_ORACLE_HOME=$answer
	done
fi
	
check_sqlplus	

if [ $chksqlp -eq 1 ]; then
 if [ "$LICAGREE" = "YES" ]; then
	log_write "sqlplus executable was not found in $V_ORACLE_HOME/bin"
	log_write "Failed to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}"
	echo  "DB: LMS-02010: Access error on ORACLE_HOME: ${V_ORACLE_HOME}" >>$log_err
	exit
 else
	question="Do you want to re-enter the location for ORACLE_HOME"
	ask_yn
	if [ "$yn" = "n" ]; then
	    log_write "Enter ORACLE_HOME answer = $yn"
		exit
	else
		V_ORACLE_HOME=""
		check_oracle_home
	fi
 fi
fi 
}


#main
#setAlias

OS_NAME=`uname -s`
NOW="`date '+%Y%m%d%H%M'`"
V_PWD="${LMSCT_TMP}/db_tmp" 
V_TMP="${LMSCT_TMP}" 
#V_PWD_TMP="${V_PWD}/lmsctdb"


V_ORACLE_HOME=$1
V_ORACLE_SID=$2
V_OS_USER=$3
SQL_SCRIPT=$4

logfile=db_conn_coll.log
log_col=DB_collected.log
log_warn=DB_warnings.log
log_err=DB_errors.log

get_USR_ID
log_write "SCRIPT_USER=$USR_ID" 

if [ "$V_OS_USER" != "$USR_ID" ] ; then
 if [ $USR_ID != "root" ] && [ "$LICAGREE" = "YES" ]; then
	log_write "Unable to switch user from $USR_ID to $V_OS_USER in silent mode"
	log_write "Unable to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}"
	exit
 else
	$ECHO Switching user from $USR_ID to $V_OS_USER...
	log_write "Switching user from $USR_ID to $V_OS_USER"

	if [ ! -w $V_TMP ]; then
		$ECHO "There are no writing permission on $V_TMP folder"
		echo "There are no writing permission on $V_TMP folder" >>"$logfile"
		echo "Failed to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}" >>"$logfile"
		grep 'LMS-02013' "$log_err" >/dev/null 2>&1
        if [ $? -eq 1 ] ; then
			echo "DB: LMS-02013: No writing permission on $V_TMP folder"  	>>"$log_err"
		fi	
		exit 201
	fi	
	
	if [ ! -x $V_TMP ]; then
		$ECHO "There are no execution permission on $V_TMP folder"
		echo "There are no execution permission on $V_TMP folder" >>"$logfile"
		echo "Failed to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}" >>"$logfile"
		grep 'LMS-02012' "$log_err" >/dev/null 2>&1
        if [ $? -eq 1 ] ; then
			echo  "DB: LMS-02012: No execute permission on $V_TMP folder" 	>>"$log_err"
		fi
		exit 201
	fi		
	
	./check_privs.sh
    	
	if [ ! -s $V_PWD/check_privs.log ] || [ ! -x $V_TMP ] ; then
		$ECHO "There are no execution permission on $V_TMP folder"
		log_write "There are no execution permission on $V_TMP folder" 
		log_write "Failed to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}" 
		grep 'LMS-02012' $log_err >/dev/null 2>&1
        if [ $? -eq 1 ] ; then
			echo  "DB: LMS-02012: No execute permission on $V_TMP folder" 	>>"$log_err"
		fi
		exit 201
	else
        rm -f $V_PWD/check_privs.log
	fi	
    
	chmod -R 777 $V_PWD
	su "$V_OS_USER" -c "cd $V_PWD; ./local_conn.sh $1 $2 $3 \"$4\""
 fi	
else

 if [ "$V_ORACLE_HOME"  = "UNKNOWN" ];then
   echo "Current User=$USR_ID" >>look_for_running_sids.log
   PMONPID=`ps -ef | grep ora_pmon_${V_ORACLE_SID} | grep -v grep | awk '{print $2}'`
     	if [ "$OS_NAME" = "SunOS" ] ; then
			echo "#/usr/bin/pwdx $PMONPID 2>/dev/null" >>look_for_running_sids.log
			/usr/bin/pwdx $PMONPID 2>/dev/null >>look_for_running_sids.log
			echo "#/usr/bin/pargs -e $PMONPID 2>/dev/null | grep 'ORACLE_'" >>look_for_running_sids.log
			/usr/bin/pargs -e $PMONPID 2>/dev/null | grep 'ORACLE_' >>look_for_running_sids.log	
			V_ORACLE_HOME=`pargs -e $PMONPID 2>/dev/null | grep ' ORACLE_HOME=' | cut -d'=' -f2`
		elif [ "$OS_NAME" = "AIX" ] ; then
			echo "#ls -l /proc/$PMONPID/cwd 2>/dev/null" >>look_for_running_sids.log
			ls -l /proc/$PMONPID/cwd 2>/dev/null >>look_for_running_sids.log
			echo "#ps eauwww $PMONPID 2>/dev/null | grep 'ORACLE_'" >>look_for_running_sids.log
			ps eauwww $PMONPID 2>/dev/null | grep 'ORACLE_' >>look_for_running_sids.log
			V_ORACLE_HOME=`ps eauwww $PMONPID 2>/dev/null |  tr ' ' '\012' | grep '^ORACLE_HOME=' | cut -d'=' -f2`
		elif [ "$OS_NAME" = "Linux" ] ; then
			echo "#/usr/bin/pwdx $PMONPID 2>/dev/null" >>look_for_running_sids.log
			/usr/bin/pwdx $PMONPID 2>/dev/null >>look_for_running_sids.log
			echo "#/usr/bin/strings /proc/$PMONPID/environ 2>/dev/null | grep 'ORACLE_'" >>look_for_running_sids.log
			/usr/bin/strings /proc/$PMONPID/environ 2>/dev/null | grep 'ORACLE_' >>look_for_running_sids.log
			V_ORACLE_HOME=`strings /proc/$PMONPID/environ 2>/dev/null | grep -v denied | grep '^ORACLE_HOME=' | cut -d'=' -f2`
		elif [ "$OS_NAME" = "HP-UX" ] ; then
			echo "#/usr/bin/pfiles $PMONPID 2>/dev/null" >>look_for_running_sids.log
			/usr/bin/pfiles $PMONPID 2>/dev/null >>look_for_running_sids.log
			V_ORACLE_HOME=`pfiles $PMONPID 2>/dev/null | grep bin |  cut -d':' -f2 | sed  -e 's/ //g' -e 's/\/bin\/oracle//g'`
		fi
 fi		
 
 #$ECHO "CONNECTION TYPE:LOCAL, ORACLE_SID:$V_ORACLE_SID, ORACLE_HOME:$V_ORACLE_HOME"
 check_oracle_home
  
   NLS_LANG=AMERICAN_AMERICA.UTF8
   export NLS_LANG
   ORACLE_HOME=$V_ORACLE_HOME
   ORACLE_SID=$V_ORACLE_SID
   export ORACLE_HOME
   export ORACLE_SID
    
   if [ "$LD_LIBRARY_PATH" != "" ]; then
     LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
   else
     LD_LIBRARY_PATH=$ORACLE_HOME/lib
   fi	
   export LD_LIBRARY_PATH
	
 log_write "Checking local connection ORACLE_SID=$V_ORACLE_SID, ORACLE_HOME=$V_ORACLE_HOME"
 
 check_space
 if [ $LMSCT_NOSPACE -eq 1 ];then
   	grep 'LMS-02019' "$log_err" >/dev/null 2>&1
    if [ $? -eq 1 ] ; then
		echo "DB: LMS-02019: ERROR: No disk space available on ${LMSCT_TMP} folder" >>"$log_err"
	fi
	exit 18
 fi	
 
  $ORACLE_HOME/bin/sqlplus /nolog  <<EOF >>$logfile 2>&1
  connect ${con_string}
  set echo off
  set verify off
  set termout off
  spool checkconn.txt
  select 'Connected' || ' successfully' from  v\$database;
  spool off
  exit
EOF
 
 if [ ! -f checkconn.txt ]; then
  $ECHO " " >checkconn.txt 
 fi

  cat checkconn.txt | grep "Connected successfully" >/dev/null
  if [ $? -eq 0 ]; then
	  log_write "Connected successfully to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}"
	  log_write "GREPME_DB_LIST>>,LOCAL,$V_ORACLE_HOME,$V_ORACLE_SID_ENV,$V_OS_USER,,,,,,,$SQL_SCRIPT,$NOW"
      $ECHO "Connected successfully"
	   sql_no=`echo $SQL_SCRIPT | tr -d ' ' | tr -s '|' ' ' | wc -w`
	   i=1; while [ $i -le $sql_no ];
	   do
	    V_SQL=`echo $SQL_SCRIPT |  cut -d'|' -f$i`
	    $ECHO "Running ${V_SQL} on local instance ${V_ORACLE_SID}..."
		log_write "Running ${V_SQL} on local instance ${V_ORACLE_SID}..."
		echo @${V_SQL} > runtime.sql
		rm -f *_sql_*.log
		$ORACLE_HOME/bin/sqlplus " ${con_string}" @runtime.sql
		i=`expr $i + 1`
		./logcolstat.sh DB NO
		./logcolstat.sh EBS NO
		done 
		log_write "End collection for ${V_ORACLE_SID}"
		log_write "=============================================================================="
		
    rm -f checkconn.txt
    
    else
     log_write "Failed to connect to local instance ${V_ORACLE_SID}, ORACLE_HOME=${V_ORACLE_HOME}, SQL=${SQL_SCRIPT}"
	 cat checkconn.txt >>$logfile
	 echo "DB: LMS-02011: Failed to connect to instance ${V_ORACLE_SID}: `egrep 'ORA-|SP2-' checkconn.txt`"  >>${log_err}
     # $ECHO "Failed to connect to local instance ${V_ORACLE_SID}"
	 rm -f checkconn.txt	 
     exit 1
  fi
 fi
 