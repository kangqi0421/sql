#!/bin/ksh

SCRIPT_VERSION="16.2"
SCRIPT_NAME=${0}

################################################################################
#
# tuxcredentialValidation - function to check the user running the script and display
# the appropriate messages. 
tuxcredentialValidation () {

	
	# 	use whoami to get user; helps in su and sudo instances; works across platforms.
	#	if whoami not found default to $LOGNAME
	USER_ID_CMD=`type whoami &>/dev/null && echo "Found" || echo "NotFound"`

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

	SCRIPT_USER=$USR_ID
	TUXDIRUSER=`ls -ld ${TUXDIR} | awk 'NR==1 {print $3}'`
	
	if [ "${SCRIPT_USER}" != "root" -o "${SCRIPT_USER}" != "${TUXDIRUSER}" ] ; then
	
		$ECHO_COUNTCLIENT "\nCurrent user "${SCRIPT_USER}" is not the owner of the Oracle Tuxedo software installation on this environment!"
		$ECHO_COUNTCLIENT "If you’re sure that the current user "${SCRIPT_USER}" is the owner of the Oracle Tuxedo software installation on this environment, continue with yes(y), otherwise select No(n) and please review the examples in the instructions document to see how to start the scripts with a user that has sufficient privileges."
		$ECHO_COUNTCLIENT "Running the LMSCollection Script with insufficient privileges may have a significant impact on the quality of the data and information collected from this environment. Due to this, Oracle LMS may have to get back to you and ask for additional items, or to execute again."
		
		ANSWER=
		while [ -z "${ANSWER}" ]
		do
			$ECHO_COUNTCLIENT "\nPlease choose an Y to continue or N to quit:"
			read ANSWER
			#
			# Act according to the user's response.
			#
			case "${ANSWER}" in
				Y|y) ANSWER=y
					;;
				N|n) ANSWER=n
					break     # break out of the loop
					;;
				#
				# An invalid choice was entered, reprompt.
				#
				*) ANSWER=
					;;
			esac
		done
		
		if [ "${ANSWER}" = "n" ] ; then
			$ECHO_COUNTCLIENT "\nUser stopped the the LMSCollection Script." >&2
			exit 0
		fi
	fi
	

}

##############################################################
# make echo more portable
#

echo_countclients() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 

# set up $ECHO_COUNTCLIENT
ECHO_COUNTCLIENT="echo_countclients"


################################################################################
#
# output welcome message.
#

beginMsg()
{
more ../resources/util/license_agreement.txt
ANSWER=

$ECHO_COUNTCLIENT "Accept License Agreement? "
	while [ -z "${ANSWER}" ]
	do
		$ECHO_COUNTCLIENT "$1 [y/n/q]:" >&2
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
# getconfigmodel() - Get Tuxedo config model
#
getconfigmodel()
{

	export FLDTBLDIR32="$TUXDIR/udataobj"
	export FIELDTBLS32="tpadm,Usysfl32"
	ud32 -C tpsysadm > domain_data.out <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_DOMAIN

!
RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Could not get the application model\n"
	$ECHO_COUNTCLIENT "Please make sure both TUXDIR and TUXCONFIG are set properly.\n"
fi

tux_model=`grep TA_MODEL ./domain_data.out  | cut -d'	' -f2`
rm -f ./domain_data.out
}


getMPboottime()
{
#TA_FILTER	33560831 - TA_TIMESTART
#TA_FILTER	33560683 - TA_CURTIME

export FLDTBLDIR32="$TUXDIR/udataobj" 
export FIELDTBLS32="tpadm,Usysfl32"
ud32 -C tpsysadm > sttime.out <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_SERVER
TA_SERVERNAME	DBBL
TA_FLAGS	65536
TA_FILTER	33560831

!
RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Could not get application start time\n"
	$ECHO_COUNTCLIENT "Please make sure both TUXDIR and TUXCONFIG are set properly.\n"
	return
fi

tmptime=`grep TA_TIMESTART ./sttime.out  | cut -d'	' -f2`
stime=`$ECHO_COUNTCLIENT "$(($tmptime/((3600*24))))"`
rm -f ./sttime.out
ud32 -C tpsysadm > curtime.out <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_SERVER
TA_SERVERNAME	DBBL
TA_FLAGS	65536
TA_FILTER	33560683

!

RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Could not get application current time\n"
	$ECHO_COUNTCLIENT "Please make sure both TUXDIR and TUXCONFIG are set properly.\n"
	return
fi
tmptime=`grep TA_CURTIME ./curtime.out  | cut -d'	' -f2`
ctime=`$ECHO_COUNTCLIENT "$(($tmptime/((3600*24))))"`
rm -f ./curtime.out

elapsedtime=`$ECHO_COUNTCLIENT "$(($ctime-$stime))"`
$ECHO_COUNTCLIENT "\nThis Server's DBBL started around $elapsedtime day(s) ago\n"
}

getSHMboottime()
{
#TA_FILTER	33560831 - TA_TIMESTART
#TA_FILTER	33560683 - TA_CURTIME

export FLDTBLDIR32="$TUXDIR/udataobj" 
export FIELDTBLS32="tpadm,Usysfl32"
ud32 -C tpsysadm > sttime.out <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_SERVER
TA_SERVERNAME	BBL
TA_FLAGS	65536
TA_FILTER	33560831

!
RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Could not get application start time\n"
	$ECHO_COUNTCLIENT "Please make sure both TUXDIR and TUXCONFIG are set properly.\n"
	return
fi

tmptime=`grep TA_TIMESTART ./sttime.out  | cut -d'	' -f2`
stime=`$ECHO_COUNTCLIENT "$(($tmptime/((3600*24))))"`
rm -f ./sttime.out
ud32 -C tpsysadm > curtime.out <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_SERVER
TA_SERVERNAME	BBL
TA_FLAGS	65536
TA_FILTER	33560683

!

RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Could not get application current time\n"
	$ECHO_COUNTCLIENT "Please make sure both TUXDIR and TUXCONFIG are set properly.\n"
	return
fi
tmptime=`grep TA_CURTIME ./curtime.out  | cut -d'	' -f2`
ctime=`$ECHO_COUNTCLIENT "$(($tmptime/((3600*24))))"`
rm -f ./curtime.out

elapsedtime=`$ECHO_COUNTCLIENT "$(($ctime-$stime))"`
$ECHO_COUNTCLIENT "\nThis Server's BBL started around $elapsedtime day(s) ago\n"
}

export tux_model

################################################################################
#
# gethighwatercnt() - check Tuxedo current client connections.
#

gethighwatercnt()
{

	export FLDTBLDIR32="$TUXDIR/udataobj"
	export FIELDTBLS32="tpadm,Usysfl32"
	ud32 -C tpsysadm <<!
SRVCNM	.TMIB
TA_OPERATION	GET
TA_CLASS	T_MACHINE
TA_FLAGS	65536
TA_FILTER	33560667
TA_FILTER	33560712

!
RETVAL=${?}
if [ ${RETVAL} -ne 0 ]
then
	$ECHO_COUNTCLIENT "Highwater mark couldn't be located, please provide to Oracle LMS the latest ULOG file of the Tuxedo domain\n"
fi
}



################################################################################
#
# checkForTux() - Make sure Tuxedo is running and env variables are set up correctly.
#
checkForTux()
{
	# Make sure a BBL is running on this machine and Tuxedo envionment variables set up correctly.
	BBLCNT=`ps -ef |grep BBL | grep -v DBBL | grep -v grep |wc -l`
	if [ ${BBLCNT} -gt 0 ]
	then 
		if [ ${BBLCNT} -gt 1 ]
		then
			$ECHO_COUNTCLIENT "NOTE: ${BBLCNT} BBL processes are running on this machine\n" >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
			$ECHO_COUNTCLIENT "There are ${BBLCNT} TUXEDO applications running on this machine\n" >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
			$ECHO_COUNTCLIENT "NOTE: ${BBLCNT} BBL processes are running on this machine\n" 
			$ECHO_COUNTCLIENT "There are ${BBLCNT} TUXEDO applications running on this machine\n"
		fi

		# Make sure necessary Environment Vars are set
		TUXDIR="${TUXDIR}"
		QUIT_COUNTCLIENTS=
		while [ -z "${TUXDIR}" -a -z "${QUIT_COUNTCLIENTS}" ]
		do
			$ECHO_COUNTCLIENT "TUXDIR not set.">&2
			$ECHO_COUNTCLIENT "Please enter the location where Tuxedo is installed,">&2
			$ECHO_COUNTCLIENT "or to quit the Tuxedo Countclients script and continue with the rest of the">&2
			$ECHO_COUNTCLIENT "LMS Collection Tool, enter [quit or q]:" >&2
			read TUXDIR

			if [ "${TUXDIR}" = "q" -o "${TUXDIR}" = "quit" -o "${TUXDIR}" = "Q" ]; then
				QUIT_COUNTCLIENTS="yes"
			elif [ ! -d "${TUXDIR}/udataobj" ]; then 
				$ECHO_COUNTCLIENT "Tuxedo udataobj directory does not exist in ${TUXDIR} ." >&2
				$ECHO_COUNTCLIENT "Please try again." >&2
				TUXDIR=
			fi
		done
		
		if [ "${QUIT_COUNTCLIENTS}" = "yes" ]; then
			$ECHO_COUNTCLIENT "User chose to quit countclients script." >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
		else	
			tuxcredentialValidation
		
			$ECHO_COUNTCLIENT "TUXDIR=${TUXDIR}" >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
			. ${TUXDIR}/tux.env
			
			
			TUXCONFIG="$TUXCONFIG"
			while [ -z "${TUXCONFIG}" -a -z "${QUIT_COUNTCLIENTS}" ]
			do
				$ECHO_COUNTCLIENT "TUXCONFIG not set">&2
				$ECHO_COUNTCLIENT "Please enter the location of TUXCONFIG,">&2
				$ECHO_COUNTCLIENT "or to quit the Tuxedo Countclients script and continue with the rest of the">&2
				$ECHO_COUNTCLIENT "LMS Collection Tool, enter [quit or q]:" >&2
				read TUXCONFIG

				if [ "${TUXCONFIG}" = "q" -o "${TUXCONFIG}" = "quit" -o "${TUXCONFIG}" = "Q" ]; then
					QUIT_COUNTCLIENTS="yes"
				elif [ ! -f "${TUXCONFIG}" ]; then 
				
					$ECHO_COUNTCLIENT "TUXCONFIG does not exist." >&2
					$ECHO_COUNTCLIENT "Please try again." >&2
					TUXCONFIG=
				fi
			done
			
			if [ "${QUIT_COUNTCLIENTS}" = "yes" ]; then
				$ECHO_COUNTCLIENT "User chose to quit countclients script." >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				$ECHO_COUNTCLIENT "User chose to quit countclients script." 

			else	
				export TUXCONFIG="${TUXCONFIG}"
				$ECHO_COUNTCLIENT "TUXCONFIG=${TUXCONFIG}" >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt

				getconfigmodel >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				if [ "${tux_model}" = "SHM" ]
				then
					getSHMboottime >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				else
					getMPboottime >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				fi
				gethighwatercnt >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				RETVAL=${?}
				if [ ${RETVAL} -ne 0 ]
				then
					$ECHO_COUNTCLIENT "Could not connect to the running application to get the Tuxedo client count."  >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt			
				fi
				$TUXDIR/bin/tmunloadcf >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
				RETVAL=${?}
				if [ ${RETVAL} -ne 0 ]
				then
					$ECHO_COUNTCLIENT "Could not get application configuration, please provide to Oracle LMS the latest ULOG file of the Tuxedo domain" >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
					$ECHO_COUNTCLIENT "Could not get application configuration, please provide to Oracle LMS the latest ULOG file of the Tuxedo domain"							
				fi
				exit 0
			fi
		fi
	else
		$ECHO_COUNTCLIENT "No Tuxedo BBL processes found on this machine."  >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
		$ECHO_COUNTCLIENT "Countclients configuration gathering script not run."  >> $LMSCT_TMP\${MACHINE_NAME}-countclients.txt
		$ECHO_COUNTCLIENT "No Tuxedo BBL processes found on this machine." 
		$ECHO_COUNTCLIENT "Countclients configuration gathering script not run."		
		exit 4
	fi 
}



################################################################################
#
#*********************************** MAIN **************************************
#
################################################################################

# command line defaults
SCRIPT_OPTIONS=
OUTPUT_DIR="."
DEBUG="false"
MACHINE_NAME=`uname -n`

STANDALONE=
# check to see if LMSCollection is running, if not then print license.
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

checkForTux
