#!/bin/sh
SCRIPT_VERSION="18.1($LMSCT_BUILD_VERSION)"

setAlias() {
	unalias -a
	 
	cmd_list="printf
	echo
	touch
	cat
	more
	grep
	egrep
	cut
	find
	uname
	awk
	sed
	sort
	uniq
	expr
	cksum
	ps
	rm
	mkdir
	mv
	ls
	clear
	"
	 
	path_list="/bin/
	/usr/bin/"
	 
	alias_not_found="" 
	for c in $cmd_list
	do
		alias_flag=0
		 
		for p in $path_list
		  do 
		   if [ -x ${p}${c} ];
		   then
						alias ${c}=${p}${c}
						alias_flag=1
						break
		  fi
		  done    
		if [ $alias_flag -eq 0 ] ; then
		   if [ -z  "${alias_not_found}" ]; then
			  alias_not_found=$c
		   else       
			 alias_not_found=${alias_not_found},$c
		   fi            
		 fi
	done
	
	if [ -n "${alias_not_found}" ]; then 
	  $ECHO "\n${alias_not_found} utility(ies) not found. Please contact Oracle LMS team."
	  exit 600
	fi
	#alias
}

echo_print() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
}

ECHO="echo_print"
setAlias

$ECHO "Starting run_opmnctl_status.sh script"
MACHINE_NAME=`uname -n`
LMS_TEMPFILE=`ls -Art $LMSCT_TMP/logs | grep LMSfiles | tail -1`
if [ ! -d "${LMSCT_TMP}/FMW" ] ; then
	mkdir -p "${LMSCT_TMP}/FMW" 
fi	
LMS_OPMN_OUT_FILE=$LMSCT_TMP/FMW/${MACHINE_NAME}-opmn_output.txt
HM_NO=0
$ECHO "SCRIPT_VERSION = $SCRIPT_VERSION" > $LMS_OPMN_OUT_FILE
$ECHO "=============================================================================" >> $LMS_OPMN_OUT_FILE
for LOC in `cat $LMSCT_TMP/logs/$LMS_TEMPFILE | grep "bin/opmnctl" | grep -v "opmnctl.tmp"`
do
	HM_NO=`expr $HM_NO + 1`;
	$ECHO "Home$HM_NO:  Oracle Home = $LOC" | sed "s/\/opmn\/bin\/opmnctl//g" | sed "s/\/bin\/opmnctl//g" >> $LMS_OPMN_OUT_FILE
	$ECHO "----------------" >> $LMS_OPMN_OUT_FILE
	$LOC status >> $LMS_OPMN_OUT_FILE 2>&1
	$ECHO "=============================================================================" >> $LMS_OPMN_OUT_FILE
done
