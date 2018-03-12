#!/bin/sh
. ./helper_functions.sh

structure=$1
db_file=$2


if [ -f "$db_file" ]; then
 max_row_id=`cat  $db_file | wc -l`
else
 $ECHO "no csv file" 
 exit 1
fi

if [ "$LMSCT_ROWID" = "" ] || [ "$LMSCT_ROWID" = "EOF" ] ; then
  LMSCT_ROWID=0
fi

lmsct_next_rowid=`expr $LMSCT_ROWID + 1`
lmsct_first_line_cm=`cat $db_file | head -${lmsct_next_rowid} | tail -1 | cut -d',' -f1`
if [ "$lmsct_first_line_cm" = "CONNECTION_METHOD" ]; then
	lmsct_next_rowid=`expr $lmsct_next_rowid + 1`
fi

#structure=`echo $structure | tr '[:upper:]' '[:lower:]`


if [ $structure = "db" ]; then

if [ $lmsct_next_rowid -gt $max_row_id ]; then
   LMSCT_ROWID="EOF"
   LMSCT_CONNECTION_METHOD=""
   LMSCT_ORACLE_HOME_SERVER=""
   LMSCT_ORACLE_SID=""
   LMSCT_OS_USER=""
   LMSCT_TNS_NAME=""
   LMSCT_TNS_HOST=""
   LMSCT_TNS_PORT=""
   LMSCT_TNS_SERVICE_NAME=""
   LMSCT_TNS_SID=""
   LMSCT_DB_USER=""
   LMSCT_SQL=""
   LMSCT_PROMPT_TEXT=""
else
 line=`cat $db_file | head -${lmsct_next_rowid} | tail -1`
 
 LMSCT_ROWID=$lmsct_next_rowid
 LMSCT_CONNECTION_METHOD=`echo $line | cut -d',' -f1`
 LMSCT_ORACLE_HOME_SERVER=`echo $line | cut -d',' -f2`
 LMSCT_ORACLE_SID=`echo $line | cut -d',' -f3`
 LMSCT_OS_USER=`echo $line | cut -d',' -f4`
 LMSCT_TNS_NAME=`echo $line | cut -d',' -f5`
 LMSCT_TNS_HOST=`echo $line | cut -d',' -f6`
 LMSCT_TNS_PORT=`echo $line | cut -d',' -f7`
 LMSCT_TNS_SERVICE_NAME=`echo $line | cut -d',' -f8`
 LMSCT_TNS_SID=`echo $line | cut -d',' -f9`
 LMSCT_DB_USER=`echo $line | cut -d',' -f10`
 LMSCT_SQL=`echo $line | cut -d',' -f11`
 LMSCT_PROMPT_TEXT=`echo $line | cut -d',' -f12`
 
  export LMSCT_ROWID
  export LMSCT_CONNECTION_METHOD
  export LMSCT_ORACLE_HOME_SERVER
  export LMSCT_ORACLE_SID
  export LMSCT_OS_USER
  export LMSCT_TNS_NAME
  export LMSCT_TNS_HOST
  export LMSCT_TNS_PORT
  export LMSCT_TNS_SERVICE_NAME
  export LMSCT_TNS_SID
  export LMSCT_DB_USER
  export LMSCT_SQL
  export LMSCT_PROMPT_TEXT
 
fi
 
fi
