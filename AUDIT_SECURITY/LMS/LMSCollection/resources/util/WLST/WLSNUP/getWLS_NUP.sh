#!/bin/sh

SCRIPT_VERSION="18.1($LMSCT_BUILD_VERSION)"
SCRIPT_NAME=${0}
##########################################################################################
##   getWLS_NUP.sh     v18.1
##    - Look for WebLogic authorized users.
##

##############################################################
# make echo more portable
#

echo_printer() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 
##############################################################
# make echo more portable
#

echo_nup_log() {
	$ECHO_PRINTER "$1" 
	$ECHO_PRINTER "$1" >> $2
} 

# set up $ECHO
ECHO_PRINTER="echo_printer"

################################################################################
#
# output welcome message.
#

beginMsg()
{
cat license_agreement.txt | more
ANSWER=

$ECHO_PRINTER "Accept License Agreement? "
	while [ -z "${ANSWER}" ]
	do
		$ECHO_PRINTER "$1 [y/n/q]: \c" >&2
  	read ANSWER
		#
		# Act according to the user's response.
		#
		case "${ANSWER}" in
			Y|y)
				return 0     # TRUE
				;;
			N|n|Q|q)
				exit 1     # FALSE
				;;
			#
			# An invalid choice was entered, reprompt.
			#
			*) ANSWER=
				;;
		esac
	done
}


################################################################################
#
#*********************************** MAIN **************************************
#
################################################################################


# command line defaults
SCRIPT_OPTIONS=

STANDALONE=
# check to see if LMSCollection is running, if not then print license. also skip ECHO setup
ps -eaf | grep LMS*.sh | grep -v grep >/dev/null 2>&1
if [ $? -eq 0 ] ; then
	STANDALONE="false"
else
	STANDALONE="true"
fi

if [ "${STANDALONE}" = "true" ] ; then
	
	# print welcome message
	beginMsg 
fi	

if [ "${LICAGREE}" = "YES" ] ; then
	exit 1
fi	

PYFILE=../resources/util/WLST/WLSNUP/getWLS_NUP.py
COMPARE_RESULT_FILE=compare_result.txt
WLS_COLLECTED=$LMSCT_TMP/logs/WLS_collected.log
WLS_WARNINGS=$LMSCT_TMP/logs/WLS_warnings.log
WLS_ERRORS=$LMSCT_TMP/logs/WLS_errors.log

QUIT_WLST=
if [ -f $COMPARE_RESULT_FILE ]
then
	QUIT_WLST=`cat $COMPARE_RESULT_FILE| grep QUIT_WLST | sed -e 's/QUIT_WLST=//g'`
fi



while [ -z "${MW_HOME}" -a -z "${QUIT_WLST}" ]
do
	if [ -z "${MW_HOME}" ] ; then
		$ECHO_PRINTER "Please enter the MW_HOME location where WebLogic is installed">&2
		$ECHO_PRINTER "or to quit the WebLogic NUP script, enter [quit or q]: \n" >&2
		read MW_HOME
	fi

	if [ "${MW_HOME}" = "q" -o "${MW_HOME}" = "quit" ]; then
		QUIT_WLST="yes"
		echo QUIT_WLST="yes" > $COMPARE_RESULT_FILE

	elif [ ! -f "${MW_HOME}/oracle_common/common/bin/wlst.sh" ]; then 
		$ECHO_PRINTER "WebLogic WLST script, wlst.sh not found in ${MW_HOME}/oracle_common/common/bin/wlst.sh .\nPlease try again.\n"	
		MW_HOME=
	fi

		
done


if [ "${QUIT_WLST}" = "yes" ]; then

	echo_nup_log "LMSCT: WLS-03001: WARNING: User chose to quit WLS NUP measurement script." $WLS_WARNINGS
	
	rmdir $LMSCT_TMP/WLSNUP 2>/dev/null
else
	if [ -f $MW_HOME/wlserver/server/bin/setWLSEnv.sh ]; then
		. "$MW_HOME/wlserver/server/bin/setWLSEnv.sh"
	elif [ -f $MW_HOME/wlserver_10.3/server/bin/setWLSEnv.sh ]; then
		. "$MW_HOME/wlserver_10.3/server/bin/setWLSEnv.sh"
	fi
	
	if [ ! -d $LMSCT_TMP/WLSNUP ] ; then
		mkdir -p $LMSCT_TMP/WLSNUP 
	fi	

	## Add jar file that has 10.3 3rd party security provider classes
	CLASSPATH="${CLASSPATH}:${MW_HOME}/server/lib/wlst.jar:${MW_HOME}/server/lib/jython.jar;"

	$ECHO_PRINTER "Getting WLS Domain NUP ...">&2
	WLST_MACHINE_NAME=`uname -n`
	$MW_HOME/oracle_common/common/bin/wlst.sh ${PYFILE} ${WLST_MACHINE_NAME}

fi

