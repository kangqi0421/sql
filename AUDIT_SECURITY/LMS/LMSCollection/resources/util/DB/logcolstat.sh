#!/bin/sh

if [ $2 = "NO" ]; then 
	ls $1_sql_*.log >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		grep -h "${1}: LMS-[0-9][0-9][0-9][0-9][0-9]: WARNING:" $1_sql_*.log  >>$1_warnings.log 2>/dev/null
		grep -h "${1}: LMS-[0-9][0-9][0-9][0-9][0-9]: ERROR:" $1_sql_*.log >>$1_errors.log 2>/dev/null
		grep -h "${1}: LMS-[0-9][0-9][0-9][0-9][0-9]: COLLECTED:" $1_sql_*.log >>$1_collected.log 2>/dev/null
	fi
else #YES = final check
	grep 'LOCAL' db_list.csv >/dev/null 2>&1
	if [ $? -eq 1 ] ; then
		echo 'DB: LMS-02808: WARNING: There are no DB instances running on this machine' >>DB_warnings.log
	fi	
	if [ -s DB_collected.log ]; then
		for line in `cat DB_collected.log | grep 'DB: LMS-02000:'`
		do
		V_DB_NAME=`echo $line | cut -d' ' -f5`
		if [ -s DB_errors.log ] && [ "V_DB_NAME" != "" ] ; then
			grep -vi "DB: LMS-02011: ERROR: Failed to connect to instance ${V_DB_NAME}:" DB_errors.log >err_temp.log 
			mv err_temp.log DB_errors.log
		fi
		done
	fi	
fi
