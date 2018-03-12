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


set_IFS()
{
OLDIFS=$IFS

if [ "$OS_NAME" = "Linux" ] ; then
	IFS=$'\n'
elif [ "$OS_NAME" = "HP-UX" ] ; then
	IFS="
"
else 
	IFS='
'
fi
}

ask_yn()
{
answ=""
while [ "$answ" = "" ]
do
	$ECHO "$question (y/n)?"; read answ
	$ECHO "------------------------------------------------------------------------------"
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

is_in_conn_list()
{
in_conn_list=-1
   echo  ",$1," | grep ",$2," > /dev/null
   if [ $? = 0 ]; then
       in_conn_list=0
    else
       in_conn_list=1
    fi
 }

export_env() 
 {
   NLS_LANG=AMERICAN_AMERICA.UTF8
   export NLS_LANG
   ORACLE_HOME=$V_ORACLE_HOME
   export ORACLE_HOME
   
   if [ "$LD_LIBRARY_PATH" != "" ]; then
     LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
	 export LD_LIBRARY_PATH
   fi	
   
   chkee=0
 }

check_space() {
LMSCT_NOSPACE=0
echo "checking disk space" >checkspace.txt
if [ ! -s checkspace.txt ]; then
	LMSCT_NOSPACE=1
	LMSCT_NOSPACEFOLDER=`pwd`
	echo "DB: LMS-02019: ERROR: No disk space available on ${LMSCT_NOSPACEFOLDER} folder"
	if [ -f checkspace.txt ]; then
		rm -f checkspace.txt
	fi
else 
    rm -f checkspace.txt
fi
}

check_oracle_home()
{
if [ "$V_ORACLE_HOME" = "" ] || [ "$REMOTE_DB" = "YES" ] ; then
 if [ ! -f oracle_homes_u.txt ] ; then
  if [ -f oracle_homes_a.txt ] ; then
   if [ "$ORACLE_HOME" != "" ]; then
	echo $ORACLE_HOME >>oracle_homes_a.txt
   fi 	
   cat oracle_homes_a.txt | sort | uniq >oracle_homes_u.txt
   chmod 777 oracle_homes_u.txt
  fi
 fi 

 $ECHO "Enter a valid ORACLE_HOME location for the SQL*Plus client to be used"
 if [ -f oracle_homes_u.txt ] ; then
  echo "Location(s) found on this machine:"
  cat oracle_homes_u.txt 
  $ECHO
 fi
 
 if [ "$V_ORACLE_HOME_PREV" != "" ]; then
  ORACLE_HOME=$V_ORACLE_HOME_PREV
 fi
 
 if [ `cat oracle_homes_u.txt | wc -l` -eq 1 ] && [ "$ORACLE_HOME" = "" ] ; then 
   ORACLE_HOME=`cat oracle_homes_u.txt`
 fi  
 
 if [ "$ORACLE_HOME" = "" ]; then
     question="Enter ORACLE_HOME "
  else	 
	$ECHO "Enter ORACLE_HOME or press Return to accept the default"
     question="($ORACLE_HOME)"
  fi 
  answer=""
  while [ "$answer" = "" ]
	do
	  $ECHO  "$question"; read answer
	  $ECHO "------------------------------------------------------------------------------"
	   if [ "$ORACLE_HOME" != "" ] && [ "$answer" = "" ]; then
	     answer=$ORACLE_HOME
	  fi
	done
	V_ORACLE_HOME=$answer
	if [ "$V_ORACLE_HOME_PREV" = "" ];then
	  V_ORACLE_HOME_PREV=$answer
	fi 
	
fi  #V_ORACLE_HOME null


if [ -f $V_ORACLE_HOME/bin/sqlplus -a -x $V_ORACLE_HOME/bin/sqlplus ]; then
#	if [ -f $V_ORACLE_HOME/bin/tnsping -a -x $V_ORACLE_HOME/bin/tnsping ]; then
		chkoh=0
#	else
#		$ECHO  "tnsping is not found on $V_ORACLE_HOME/bin/ or it is not an executable"
#		chkoh=1
#	fi
else
	$ECHO  "sqlplus executable was not found in $V_ORACLE_HOME/bin."
	chkoh=1
fi		 
if [ $chkoh -eq 1 ]; then
 question="Do you want to re-enter the location for ORACLE_HOME"
 ask_yn
 if [ "$yn" = "n" ]; then
    log_write "$question answer = $yn"
	echo  "LMS-02010 : Access error on ORACLE_HOME: ${V_ORACLE_HOME}" >>$log_err
	continue
 else
	V_ORACLE_HOME=""
	check_oracle_home
 fi
else
 export_env
fi
}

check_tnsping()
{
chktnsp=1
log_write "Checking tnsping on $1"
if [ -f $V_ORACLE_HOME/bin/tnsping -a -x $V_ORACLE_HOME/bin/tnsping ]; then
	$ORACLE_HOME/bin/tnsping "$1"  >> $logfile
	if [ $? -eq 0 ]; then
		chktnsp=0
	else
		$ECHO  "TNSPING test failed for the specified connection description."
		question="Do you want to re-enter the connection details"
		ask_yn
		if [ "$yn" = "n" ]; then
			log_write "$question answer = $yn"
			continue
		else
			chktnsp=1
		fi	
	fi
else
 	chktnsp=0 
	log_write "Can't find tnsping on $V_ORACLE_HOME, unable to test the connection string"
fi
}

check_conn() 
{
log_write "Checking remote connection ${V_DB_USER}@$conn_str $sysdba"
check_space
if [ $LMSCT_NOSPACE -eq 1 ];then
    logwrite  "DB: LMS-02019: ERROR: No disk space available on ${LMSCT_NOSPACEFOLDER} folder"
	grep 'LMS-02019' $log_err >/dev/null 2>&1
    if [ $? -eq 1 ] ; then
		echo "DB: LMS-02019: ERROR: No disk space available on ${LMSCT_NOSPACEFOLDER} folder" >>$log_err
	fi
	exit 
fi

echo " " >checkconn.txt 
$V_ORACLE_HOME/bin/sqlplus /nolog  <<EOF > checkconn.log 
	set echo off
	set verify off
	set termout off
	set define off
	CONNECT ${V_DB_USER}/${pass}@"$conn_str" $sysdba
	select 'Connected' || ' successfully' from  v\$database;
	exit
EOF

cat checkconn.log | egrep 'ORA-[0-9]*:' >> $logfile
cat checkconn.log | egrep 'SP2-[0-9]*:' >> $logfile

cat checkconn.log | grep "Connected successfully" >/dev/null

if [ $? -eq 0 ]; then
	$ECHO  "Connected successfully to ${V_DB_USER}@$1 $sysdba"
	cc=0
	log_write "Connected successfully to ${V_DB_USER}@$1 $sysdba, SQL=${V_SQL}"
	log_write "GREPME_DB_LIST>>,$V_CONNECTION_METHOD,$V_ORACLE_HOME,,,$V_TNS_NAME,$V_TNS_HOST,$V_TNS_PORT,$V_TNS_SERVICE_NAME,$V_TNS_SID,$V_DB_USER,$V_SQL,$NOW"
else
	cc=1
	$ECHO  "Failed to connect to the database"
	log_write "Failed to connect to ${V_DB_USER}@$1 $sysdba"
	
	cat checkconn.log | egrep 'ORA-01017|ORA-28009|ORA-01031' >/dev/null
	if [ $? -eq 0 ]; then
		$ECHO  "Connection error: invalid username/password"
		question="Do you want to re-enter the database user and password"
		ask_yn
		if [ "$yn" = "n" ]; then
			log_write "$question answer = $yn"
			if [ !  "$REMOTE_DB" = "YES" ];then
				echo "DB: LMS-02011: Failed to connect to instance ${V_ORACLE_SID}: `egrep 'ORA-[0-9]*:' checkconn.log`"  >>$log_err
			fi
			rm -f checkconn.log
			continue
		else
			V_DB_USER=""; check_db_user
			ask_db_user_pass
			check_conn $conn_str
		fi
	else
		#$ECHO  "Errors are logged in db_conn_coll.log file"
		if [ !  "$REMOTE_DB" = "YES" ];then
			echo "DB: LMS-02011: Failed to connect to instance ${V_ORACLE_SID}: `egrep 'ORA-[0-9]*:' checkconn.log`"  >>$log_err
		fi	
	fi
fi	
rm -f checkconn.log
}

check_tns_name()
{
 if [ "$V_TNS_NAME" = "" ]; then
	$ECHO "Enter value for TNS_NAME, as registered in your Oracle Names"
	var="solution (tnsmanes.ora, Oracle Internet Directory, etc)"
    ask_variable V_TNS_NAME
  fi 
 conn_str=$V_TNS_NAME
 check_tnsping $conn_str
 if [ $chktnsp -eq 1 ];then
   	V_TNS_NAME=""
	#check_tns_name
	#ask_connection_method
 fi  
}

check_hpsn()
{
 if [ "$V_TNS_HOST" = "" ]; then
   var="Enter value for listener HOST (network name or IP address)"
   ask_variable V_TNS_HOST
  fi  
 if [ "$V_TNS_PORT" = "" ]; then
   var="Enter value for listener PORT"
   ask_variable V_TNS_PORT
 fi  
 if [ "$V_TNS_SERVICE_NAME" = "" ]; then
 $ECHO "Enter value for database SERVICE_NAME, as known by the listener."
 var="For container databases, enter the value for the CDB\$ROOT container."
 ask_variable V_TNS_SERVICE_NAME
 fi  
 
 conn_str="(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = $V_TNS_HOST)(PORT = $V_TNS_PORT)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = $V_TNS_SERVICE_NAME)))"
 check_tnsping $conn_str
 
 if [ $chktnsp -eq 1 ];then
	V_TNS_HOST=""
	V_TNS_PORT=""
	V_TNS_SERVICE_NAME=""
	#check_hpsn
	#ask_connection_method
 fi  
 }

 check_hpsid()
 {
 if [ "$V_TNS_HOST" = "" ]; then
   var="Enter value for listener HOST (network name or IP address)"
   ask_variable V_TNS_HOST
  fi  
 if [ "$V_TNS_PORT" = "" ]; then
   var="Enter value for listener PORT"
   ask_variable V_TNS_PORT
 fi  
 if [ "$V_TNS_SID" = "" ]; then
   var="Enter value for database SID"
   ask_variable V_TNS_SERVICE_NAME
 fi   

 conn_str="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$V_TNS_HOST)(PORT=$V_TNS_PORT))(CONNECT_DATA=(SID=$V_TNS_SID)))" 
 check_tnsping $conn_str
 
 if [ $chktnsp -eq 1 ];then
	V_TNS_HOST=""
	V_TNS_PORT=""
	V_TNS_SID=""
	#check_hpsid
	#ask_connection_method
 fi  
 }

ask_variable()
{
answer=""
while [ "$answer" = "" ]
	do
		$ECHO  "$var"; read answer
		$ECHO  "------------------------------------------------------------------------------"
	done
eval $1="$answer"
}		
 
check_db_user()
{
  while [ "$V_DB_USER" = "" ]
	do
		$ECHO  "Enter database user (e.g. SYS AS SYSDBA, SYSTEM, SCOTT)"; read V_DB_USER
		$ECHO  "------------------------------------------------------------------------------"
	done
	
 echo ${V_DB_USER} | grep -i "as sysdba" >/dev/null
 if [ $? = 0 ]; then
   V_DB_USER=`echo ${V_DB_USER} | cut -d' ' -f1`
   sysdba="as sysdba"
  else
   sysdba=""
  fi 	
}

check_sql_file()
{
while [ "$V_SQL" = "" ]
do
	$ECHO  "Enter value for sql file(s), separated by | "; read V_SQL
	$ECHO  "------------------------------------------------------------------------------"
done
}

ask_connection_method()
{
$ECHO "Select connection description method:"
$ECHO "  1) Enter TNS_NAME registered in your Oracle Names solution(ex. tnsmanes.ora)"
$ECHO "  2) Enter listener HOST (name or IP address), PORT and database SERVICE_NAME"
$ECHO "  3) Enter listener HOST (name or IP address), PORT and database instance SID"
$ECHO "  4) SKIP"
$ECHO "Enter selection or press Return to accept the default (2)"
read answer
$ECHO  "------------------------------------------------------------------------------"
if [ "$answer" = "" ]; then
	answer=2
fi

if  [ "$answer" = "4" ] ; then
	log_write "ask_connection_method - SKIP"
	V_CONNECTION_METHOD=SKIP
	continue
else
	if [ "$answer" = "1" ] ; then
		V_CONNECTION_METHOD=TNS_NAME
	else
		if [ "$answer" = "2" ] ; then
			V_CONNECTION_METHOD=HOST_PORT_SERVICE_NAME
		else
			if [ "$answer" = "3" ] ; then
				V_CONNECTION_METHOD=HOST_PORT_SID
			else
				ask_connection_method
			fi	
		fi	
	fi 
fi
log_write "ask_connection_method - $V_CONNECTION_METHOD"

}

ask_db_user_pass()
 {
 $ECHO "Enter password" ; stty -echo; read pass; stty echo
 $ECHO  "------------------------------------------------------------------------------"
 }
 
log_write()
{
 $ECHO  $1 >>$logfile
}

run_sql()
{
check_sql_file
check_db_user
ask_db_user_pass
 
check_conn $conn_str

if [ $cc -eq 0 ]; then
	 sql_no=`echo $V_SQL | tr -d ' ' | tr -s '|' ' ' | wc -w`
	 i=1; while [ $i -le $sql_no ];
	 do
		R_SQL=`echo $V_SQL |  cut -d'|' -f$i`
		$ECHO  "Running ${R_SQL} ..."
		log_write "Running ${R_SQL} ..."
		echo @${R_SQL} > runtime.sql
		rm -f *_sql_*.log
		$ORACLE_HOME/bin/sqlplus "${V_DB_USER}/${pass}@$conn_str $sysdba" @runtime.sql
		./logcolstat.sh DB NO
		./logcolstat.sh EBS NO
		i=`expr $i + 1`
	done
 fi 
}


check_remote_conn()
{
 if [ "$V_CONNECTION_METHOD" = "TNS_NAME" ]; then
 	check_tns_name
	conn_message="@${V_TNS_NAME}"
#	$ECHO  "CONNECTION TYPE:TNS_NAME, ORACLE_HOME:$V_ORACLE_HOME, V_TNS_NAME:$V_TNS_NAME"
 fi
 if [ "$V_CONNECTION_METHOD" = "HOST_PORT_SERVICE_NAME" ]; then
  	check_hpsn
	conn_message="on ${V_TNS_SERVICE_NAME}@${V_TNS_HOST}"
#	$ECHO  "CONNECTION TYPE:HOST_PORT_SERVICE_NAME, ORACLE_HOME:$V_ORACLE_HOME, SERVER:$V_TNS_HOST, PORT:$V_TNS_PORT, SERVICE_NAME:$V_TNS_SERVICE_NAME"
 fi
 if [ "$V_CONNECTION_METHOD" = "HOST_PORT_SID" ]; then
	check_hpsid
	conn_message="on ${V_TNS_SID}@${V_TNS_HOST}"
#	$ECHO  "CONNECTION TYPE:HOST_PORT_SID, ORACLE_HOME:$V_ORACLE_HOME, SERVER:$V_TNS_HOST, PORT:$V_TNS_PORT, SID:$V_TNS_SID"
 fi
}

remote_conn()
{
  $ECHO "------------------------------------------------------------------------------"
  $ECHO  "Entering details for connecting SQL*Plus to the database via listener."
  $ECHO  
    ask_connection_method
	  if [ "$V_CONNECTION_METHOD" != "SKIP" ] ; then
	   chkee=1
	   check_oracle_home
       if [ $chkee -eq 0 ] ; then
		check_remote_conn
		if [ $chktnsp -eq 0 ];then
		    run_sql
		else
			remote_conn
		fi	
	  fi	 
   fi
  
  if [ "$REMOTE_DB" = "YES" ] ; then
	$ECHO
	$ECHO  "------------------------------------------------------------------------------"
	question="Do you want to proceed with another database"
	ask_yn
	if [ "$yn" = "y" ]; then
		V_TNS_NAME=""
		V_TNS_HOST=""
		V_TNS_PORT=""
		V_TNS_SERVICE_NAME=""
		V_TNS_SID=""
		V_DB_USER=""
		remote_conn
	else
	  log_write "$question answer = $yn"
	  exit
	fi
  fi
}


#main 
#setAlias

db_file=$2
OS_NAME=`uname -s`
MACHINE_NAME=`uname -n`
logfile=db_conn_coll.log
log_col=DB_collected.log
log_warn=DB_warnings.log
log_err=DB_errors.log
SCRIPT_VERSION=$LMSCT_BUILD_VERSION

NOW="`date '+%Y%m%d%H%M'`"
v_counter=1

rm -f EBS_*.log
for f in $log_col $log_warn $log_err
do
	> $f
	chmod 777 $f
done

set_IFS
log_write "=============================================================================="
chmod 777 $logfile

get_USR_ID

log_write "Script Start Time=`date '+%m/%d/%Y %H:%M %Z'`"
log_write "Script Version=$SCRIPT_VERSION"
log_write "Products=$ALLPRODLIST"
log_write "Silent mode=$LICAGREE"
log_write "Remote collection=$REMOTE_DB"
log_write "Operating System Name=$OS_NAME"
log_write "Machine Name=$MACHINE_NAME"
log_write "Script User=$USR_ID" 
log_write "Tmp Dir=$LMSCT_TMP"
log_write "=============================================================================="


if [ -f "$db_file" ]; then

if [ "$REMOTE_DB" = "YES" ] ; then #remote connection
 if [ "$LICAGREE" != "YES" ]; then #no silent mode
  V_SQL="db_conn_coll_main.sql NO $vprodlist"
  remote_conn
  else
	log_write "Skip remote connections in silent mode"
 fi

else #local connections

if [ "$1" = "YES" ] ||  [ "$1" = "yes" ] ; then
   cat $db_file | grep "^CONNECTION_METHOD"
	if [ $? = 0 ]; then
		v_counter=0
	else
		v_counter=1
    fi	  
   cat $db_file | grep -v "^CONNECTION_METHOD" | cat -n
   $ECHO  "Enter the connection number(s)"
   read conn_list
   $ECHO "------------------------------------------------------------------------------"
fi

for line in `cat $db_file`
#cat $db_file | while read line
do
 V_CONNECTION_METHOD=`echo $line | cut -d',' -f1`
 V_ORACLE_HOME=`echo $line | cut -d',' -f2`
 V_ORACLE_SID=`echo $line | cut -d',' -f3`
 V_OS_USER=`echo $line | cut -d',' -f4`
 V_TNS_NAME=`echo $line | cut -d',' -f5`
 V_TNS_HOST=`echo $line | cut -d',' -f6`
 V_TNS_PORT=`echo $line | cut -d',' -f7`
 V_TNS_SERVICE_NAME=`echo $line | cut -d',' -f8`
 V_TNS_SID=`echo $line | cut -d',' -f9`
 V_DB_USER=`echo $line | cut -d',' -f10`
 V_SQL=`echo "$line" | cut -d',' -f11`

 is_in_conn_list $conn_list $v_counter
 v_counter=`expr $v_counter + 1`
  
 if  [ "$1" = "no" ] || [ "$1" = "NO" ] || [ "$in_conn_list" = 0 ]; then #collect db_list
  
 if [ "$V_CONNECTION_METHOD" = "CONNECTION_METHOD" ]; then
   	 continue
 fi
 
 if [ "$V_CONNECTION_METHOD" = "LOCAL" ]; then
	#$ECHO "------------------------------------------------------------------------------"
	log_write "Start colecting data for local instance $V_ORACLE_SID"
	 ./local_conn.sh $V_ORACLE_HOME $V_ORACLE_SID $V_OS_USER "$V_SQL"
	 status=${?}
	 if [ $status -eq 201 ]; then continue ; fi
	 if [ $status -eq 18 ]; then 
	   grep 'LMS-02019' $log_err >/dev/null 2>&1
       if [ $? -eq 1 ] ; then
			echo "DB: LMS-02019: ERROR: No disk space available" >>$log_err
	   fi
	   exit
	 fi	
	 if [ $status -eq 1 ] && [ "$LICAGREE" != "YES" ]; then #local failed, no silent mode
		$ECHO  "------------------------------------------------------------------------------"
		$ECHO  "Failed to connect \"sqlplus / as SYSDBA\" using:"
		$ECHO  "OS user: $V_OS_USER"
		$ECHO  "ORACLE_SID: $V_ORACLE_SID"
		$ECHO  "ORACLE_HOME: $V_ORACLE_HOME"
		$ECHO  "(errors are logged in db_conn_coll.log file)"
		$ECHO  "Common cause: the database is not properly open or mounted."
		$ECHO
		$ECHO  "You can address the error and rerun the tool later or, alternately,"
		$ECHO  "you can continue now by trying to connect to this database via listener."
		$ECHO
		remote_conn
	  else
		continue
	 fi
 else	 
	if [ "$LICAGREE" != "YES" ]; then
		remote_conn
	else
		log_write "Skip remote connection (CONNECTION TYPE:$V_CONNECTION_METHOD) in silent mode"
	fi
 fi
 
fi	# end collect db_list
done  

fi #remote/local
fi #$db_file

IFS=$OLDIFS

log_write "#Troubleshooting"
log_write "------------------------------------------------------------------------------"
log_write "#df -k ${LMSCT_TMP}" 
df -k "${LMSCT_TMP}" >>$logfile
log_write "------------------------------------------------------------------------------"
ls -Rl  >>$logfile

if [ -f "look_for_running_sids.log" ]; then
  log_write "------------------------------------------------------------------------------"
  cat look_for_running_sids.log >>$logfile
  rm -f look_for_running_sids.log 
fi
log_write "------------------------------------------------------------------------------"
log_write "Script End Time=`date '+%m/%d/%Y %H:%M %Z'`"