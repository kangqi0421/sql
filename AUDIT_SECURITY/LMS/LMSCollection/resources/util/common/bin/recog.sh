#!/bin/sh

SCRIPT_VERSION="18.1($LMSCT_BUILD_VERSION)"
SCRIPT_NAME=${0}
##########################################################################################
##   recog.sh     v 18.1
##    - REmote COpy and Gathering script. 
##	  - Connects to remote machine, copys LMSCollection scripts, gathers data and returns.
##
LMSCOLLECTIONZIP=../../Oracle_LMS_Collection_Tool.zip
REMOTEMACHINE=
REMOTEDIR=
REM_SCRIPT_OPTIONS=
REMCOG_COLLECTED=output/logs/REMCOG_collected.log
REMCOG_WARNINGS=output/logs/REMCOG_warnings.log
REMCOG_ERRORS=output/logs/REMCOG_errors.log
RUN_AS_SUDO=

ECHO_recog="echo_recog_print"
##############################################################
# make echo more portable
#

echo_recog_print() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 

##############################################################
# make echo more portable
#

echo_recog_log() {
	$ECHO_recog "$1" 
	$ECHO_recog "$1" >> $2
} 


##############################################################
# recog_connect()  - connect based on REMOTEINFO
#
recog_connect() {

	$ECHO_recog "\nGetting remote machine name\n"
	REM_MACHINE_NAME=`ssh $REMOTEINFO $RUN_AS_SUDO uname \-n`
	
	$ECHO_recog "\nCreating directory on $REM_MACHINE_NAME\n"

	# make temp directory on remote machine 
	ssh $REMOTEINFO "$RUN_AS_SUDO mkdir -p /tmp/LMSrecog ; $RUN_AS_SUDO chmod -R 777 /tmp/LMSrecog"
	if [ ${?} -ne 0 ] ; then
		echo_recog_log "LMSCT: RECOG-05000: ERROR: Error creating directory on remote machine." $REMCOG_ERRORS
		return 1
	fi

	$ECHO_recog "\nCopying LMS Collection Tool files to remote machine.\n"
	#copy LMSCollection tool
	scp $LMSCOLLECTIONZIP $REMOTEINFO:/tmp/LMSrecog/.
	if [ ${?} -ne 0 ] ; then
		echo_recog_log "LMSCT: RECOG-05001: ERROR: Error  copying LMS Collection Tool files to remote machine." $REMCOG_ERRORS
		return 1
	fi
	$ECHO_recog "\nUnzipping LMS Collection Tool files to remote machine\n"
	# Unzip the tool, use -o to extrat only new files and not prompt user.
	ssh  $REMOTEINFO $RUN_AS_SUDO unzip -q -o /tmp/LMSrecog/Oracle_LMS_Collection_Tool.zip -d /tmp/LMSrecog
	if [ ${?} -ne 0 ] ; then
		echo_recog_log "LMSCT: RECOG-05002: ERROR: Error  unzipping LMS Collection Tool files to remote machine." $REMCOG_ERRORS
		return 1
	fi

	$ECHO_recog "\nSetting up permissions on remote machines\n"
	# run LMSCollection Tool
	ssh  $REMOTEINFO $RUN_AS_SUDO chmod -R 777 /tmp/LMSrecog
	if [ ${?} -ne 0 ] ; then
		echo_recog_log "LMSCT: RECOG-05003: ERROR: Error setting up permissions on remote machines." $REMCOG_ERRORS	
		return 1
	fi

	$ECHO_recog "\nRunning LMS Collection Tool on remote machine with options: $REM_SCRIPT_OPTIONS \n"
	ssh $REMOTEINFO "cd /tmp/LMSrecog/LMSCollection/bin/ ; $RUN_AS_SUDO sh LMSCollection.sh $REM_SCRIPT_OPTIONS ; $RUN_AS_SUDO chmod -R 777 output"
	if [ ${?} -ne 0 ] ; then
		echo_recog_log "LMSCT: RECOG-05004: ERROR: Error  running LMS Collection Tool on remote machine." $REMCOG_ERRORS	
		return 1
	fi

	if [ "$MASK_DATA" != "" ] ; then
		LMS_REM_TAR_FILE=/tmp/LMSrecog/LMSCollection/bin/output/LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}-masked.tar
		LOCAL_OUTPUT_FILE=${LOCAL_OUTPUT_DIR}/LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}-masked.tar
		LMS_REM_DEBUG_TAR_FILE=/tmp/LMSrecog/LMSCollection/bin/output/debug_LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}-masked.tar
		LOCAL_DEBUG_OUTPUT_FILE=${LOCAL_OUTPUT_DIR}/debug_LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}-masked.tar
	else
		LMS_REM_TAR_FILE=/tmp/LMSrecog/LMSCollection/bin/output/LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}.tar
		LOCAL_OUTPUT_FILE=${LOCAL_OUTPUT_DIR}/LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}.tar
		LMS_REM_DEBUG_TAR_FILE=/tmp/LMSrecog/LMSCollection/bin/output/debug_LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}.tar
		LOCAL_DEBUG_OUTPUT_FILE=${LOCAL_OUTPUT_DIR}/debug_LMSCollection-${REM_MACHINE_NAME}${PRODUCTSRUN}.tar		
	fi

	clear

	TARTIMESTAMP=`date '+%Y%m%d_%H%M%S'`
	# check if compressed archive file exists, if so move older one.
	if [ -f $LOCAL_OUTPUT_FILE.bz2 ] ; then
		mv $LOCAL_OUTPUT_FILE.bz2 $LOCAL_OUTPUT_FILE.bz2.$TARTIMESTAMP
		mv $LOCAL_DEBUG_OUTPUT_FILE.bz2 $LOCAL_DEBUG_OUTPUT_FILE.bz2.$TARTIMESTAMP

	fi
	if [ -f $LOCAL_DEBUG_OUTPUT_FILE.Z ] ; then
		mv $LOCAL_OUTPUT_FILE.Z $LOCAL_OUTPUT_FILE.Z.$TARTIMESTAMP
		mv $LOCAL_DEBUG_OUTPUT_FILE.Z $LOCAL_DEBUG_OUTPUT_FILE.Z.$TARTIMESTAMP
	fi
	
	# gather results
	$ECHO_recog "\nCopying the archive from the remote machine...\n"
	scp $REMOTEINFO:${LMS_REM_TAR_FILE}.bz2 ${LOCAL_OUTPUT_DIR}/.
	if [ ${?} -ne 0 ] ; then
		scp $REMOTEINFO:${LMS_REM_TAR_FILE}.Z ${LOCAL_OUTPUT_DIR}/.
		if [ ${?} -ne 0 ] ; then
			scp $REMOTEINFO:${LMS_REM_TAR_FILE} ${LOCAL_OUTPUT_DIR}/.
			if [ ${?} -ne 0 ] ; then
				echo_recog_log "LMSCT: RECOG-05005: ERROR: Unable to collect ${LMS_REM_TAR_FILE} from the remote system. Please see documentation for troubleshooting information." $REMCOG_ERRORS
			else 
				echo_recog_print "Please forward ${LOCAL_OUTPUT_FILE} to your LMS Contact"
			fi
		else
			echo_recog_print "Please forward ${LOCAL_OUTPUT_FILE}.Z to your LMS Contact"
		fi
	else
			echo_recog_print "Please forward ${LOCAL_OUTPUT_FILE}.bz2 to your LMS Contact"
	fi
	

	$ECHO_recog "\nCopying the debug logs from the remote machine...\n"
	scp $REMOTEINFO:${LMS_REM_DEBUG_TAR_FILE}.bz2 ${LOCAL_OUTPUT_DIR}/.
	if [ ${?} -ne 0 ] ; then
		scp $REMOTEINFO:${LMS_REM_DEBUG_TAR_FILE}.Z ${LOCAL_OUTPUT_DIR}/.
		if [ ${?} -ne 0 ] ; then
			scp $REMOTEINFO:${LMS_REM_DEBUG_TAR_FILE} ${LOCAL_OUTPUT_DIR}/.
			if [ ${?} -ne 0 ] ; then
				echo_recog_log "LMSCT: RECOG-05005: ERROR: Unable to collect ${LOCAL_DEBUG_OUTPUT_FILE} from the remote system. Please see documentation for troubleshooting information." $REMCOG_ERRORS
			else 
				echo_recog_print "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LOCAL_DEBUG_OUTPUT_FILE"
			fi
		else
			echo_recog_print "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LOCAL_DEBUG_OUTPUT_FILE.Z"
		fi
	else
			echo_recog_print "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LOCAL_DEBUG_OUTPUT_FILE.bz2"
	fi

}
##############################################################
# setArgs()  - setup args
#
setArgs () {
	PRODUCTSRUN=
	while [ "$1" != "" ]
	do
		case $1 in
			-p)
				REMOTEPRODARGS="$1 $2"
				REMOTEPRODLIST=$2
				shift 2
				;;
			-sudo)
				RUN_AS_SUDO="sudo"
				shift
				;;					
			*\@*) 		
				REMOTEINFO=$1
				shift
				;;
		esac
	done
	
	if [ "$REMOTEPRODLIST" = "all" ] ; then
		PRODUCTSRUN="_all"
	else
		RMTMPPLIST="$REMOTEPRODLIST"
		REMOTEPRODLIST=
		PRODUCTSRUN=
		for RMCHOSENPROD in `echo $RMTMPPLIST | tr ',' ' '`
		do
			PRODUCTSRUN="${PRODUCTSRUN}_${RMCHOSENPROD}"
		done		
	fi
}

LOCAL_OUTPUT_DIR=${OUTPUT_DIR}

# set up args, remove -r argument from remote running of the script to avoid loop.
while [ "$1" != "" ]
do
	case $1 in
	-r) # ignore -r for remote run
		shift 2
		;;    				
	-o) # ignore output for remote run put it in local tmp/LMSrecog
		shift 2
		;;   
	-L) # ignore -L for remote run we automatically add it.
		shift 2
		;;
	*) 
		if [ "$1" = "-fastsearch" ] ; then
			REM_SCRIPT_OPTIONS="$REM_SCRIPT_OPTIONS $1"
			shift 1
		else
			REM_SCRIPT_OPTIONS="$REM_SCRIPT_OPTIONS $1 $2"
			shift 2
		fi
		;;
	esac
done

# in Remote Connection mode run script without license prompt
REM_SCRIPT_OPTIONS="$REM_SCRIPT_OPTIONS -L Y"

# If products where chosen via the menu, add PRODUCTSRUN to options
if [ "$REMOTE_PROD_OPTS" != "" ] ; then
	RMPRODS=${REMOTE_PROD_OPTS:1}
	REM_SCRIPT_OPTIONS="$REM_SCRIPT_OPTIONS -p $RMPRODS"
fi

REMOTEFILENAME=
case "$REMOTEINFO" in
  *\@*) 
	# Remote usage specified on command line
	recog_connect
	;;
  *)     
	REMOTEFILENAME=$REMOTEINFO
	$ECHO_recog "\nReading $REMOTEINFO..." 
	old_IFS=$IFS      # save the field separator           
	IFS=$'\n'     # new field separator, the end of line     
	for remoteIn in `cat $REMOTEFILENAME`
	do
		case "$remoteIn" in
			"#"* )
				;;
			"" )
				;;
			*\@*) 
				IFS=' '
				setArgs $remoteIn
				REM_SCRIPT_OPTIONS="$REM_SCRIPT_OPTIONS $REMOTEPRODARGS"
				$ECHO_recog "\nExecuting remote LMS Collection for $REMOTEINFO $REM_SCRIPT_OPTIONS..." 
				recog_connect
				IFS=$'\n'
				;;
		esac
	done
	IFS=$old_IFS     # restore default field separator 
esac
