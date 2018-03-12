#!/bin/sh

################################################################################
# LMSCollection.sh 
# 	This script is used to search for all the installed instances of Oracle  
# 	products in the target system. 
#
################################################################################

LMSCT_BUILD_VERSION="18.1.2"
export LMSCT_BUILD_VERSION
SCRIPT_VERSION="18.1.2"
SCRIPT_NAME="${0}"

################################################################################
#
#********************User Command Line Management Utilities*********************
#
################################################################################


################################################################################
#
# function to syntax check and process the command line options
#

checkSyntax() {

	ARGUSAGE="\nOptions are: \n
	[-d search_dir] [-fsall true|false] [-o full_path_dir_name] 
	[-follow true|false] [-debug true|false] [-m all|ip|user] [-tns]
	[-L Y|N ] [-p product] [-fastsearch] -r [remote_user@remote_machine] -t [tempdir]
	
	-d [search,dirs]
		The directories to be searched for the 
		installations. A quoted string of directory names
		separated by a comma is required for when
		more than 1 directory is to be searched. The 
		default is the root directory. 
	
	-fsall [true|false]
		When specified true, all file systems including
		remote ones are searched, otherwise	only local
		filesytem is searched.  Default is false.

	-o [full_path_dir_name]
		Option to output to a file in the
		directory specified by full_path_dir_name. The option should
		be a full pathname. The file will be named LMSCollection-<MACHINE_NAME>.tar.bz2.
		If not specified, default is the current directory.
		
	-follow [true|false]	
		Option to follow symbolic links during file search.
		Default action is true. Some older versions of
		AIX don't allow the find command to follow
		symbolic links, so this must be set to false for
		the script to work with those systems.
		
	-debug [true|false]	
		Option to turn on debugging information. Default false. 
	
	-m [ip|user|all]		
		Option to turn on masking of sensitive information.
		Default is off, can mask username/password combination
		or IP address.
	
	-L Y	
		Option to agree to license agreement without having it 
		displayed. Default is off, so the License Agreement will
		be printed to the screen. 
		
		NOTE: ***USE OF THIS OPTION IMPLIES LICENSE ACCEPTENCE.***
	
	-fastsearch	
		Option to automatically detect Oracle directories to be
		searched. NOTE: The fastsearch option of LMSCollection
		is intended to gather information from the system with 
		minimal file searching. 
	
	-p product	
		Option to pass in a list of Oracle products to look for.
		Use \"all\" for the products that the LMS Collection 
		Tool supports. Use a comma separated list for a group
		of products.  i.e.	\"FormsReports, WLS,SOA,WLSNUP,OAS,
		Tuxedo,WLSBasic,DB,EBS,OBI,Webcenter\"
		
	-r [file.txt|remote_user@remote_machine]
		Option to run the LMSCollection Scripts remotely and gather
		results.  If used, the LMSCollection tool will secure copy
		files to remote_machine and run the script from /tmp.
	
	-tns 
		Option to switch from the automatic local database connection
		mode (the default) to an interactive remote database connection
		mode, via database listener. The tool prompts for connection
		description details (e.g. listener host, port, etc), database
		user and password, then connects to the remote database using 
		SQL*Plus and collects the data for the selected products
		(DB, EBS).  Multiple databases can be collected. This mode 
		cannot be used together with the silent mode (-L Y).
	
	-t [full_path_dir_name]
		Option to set the LMS Collection Tool temporary output to files in the
		directory specified by full_path_dir_name. The option should
		be a full pathname. The files will be deleted at the end of the LMSCT
		run.  If not specified default is /tmp.
		
	"
		

	while [ "$1" != "" ]
	do
	    case $1 in
		-d) SEARCH_DIR="$2" ;
			if [ ! -z "$SEARCH_DIR" ] ; then
				for DIR in `$ECHO "$SEARCH_DIR" | tr ',' ' '`
				do	
				if [ ! -d ${DIR} ] ; then
					$ECHO "\n$ARGUSAGE" >&2
					$ECHO "LMSCT: LMS-00001: ERROR: Argrument search directory $DIR does not exist or is not readable."
					exit 0
				fi
				done
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 ${2}"
				SEARCH_DIR=`$ECHO $SEARCH_DIR | tr ',' ' '`
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00002: ERROR: No argument provided to the -d parameter."
				exit 0
			fi
			;;
		-fsall) FS_SEARCH_ALL=$2 ;
			if [ ! -z "$FS_SEARCH_ALL" ] ; then
				if [ "$FS_SEARCH_ALL" = "false" ] ; then
					SEARCH_NFS="false"
				else
					SEARCH_NFS="true"
				fi
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00003: ERROR:  No argument provided to the -fsall parameter."				
				exit 0
			fi			
			;;
		-o) OUTPUT_DIR=$2 ;	
			if [ ! -z "$OUTPUT_DIR" ] ; then
				if [ ! -d "${OUTPUT_DIR}" ] ; then
					mkdir -p "${OUTPUT_DIR}" 
					mkdir -p "${LMSCT_DEBUG}"
				fi			
				if [ ! -w "${OUTPUT_DIR}" ] ; then
					$ECHO "\n$ARGUSAGE" >&2
					$ECHO "LMSCT: LMS-00004: ERROR:  User does not have the permission to write to the created subfolder, ${OUTPUT_DIR}."						
					exit 0
				fi			
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00005: ERROR:  No argument provided to the -o parameter."					
				exit 0
			fi				
			;;
		-follow) FOLLOW_ALL=$2 ;
			if [ ! -z "$FOLLOW_ALL" ] ; then		
				if [ "$FOLLOW_ALL" = "false" ] ; then
					FOLLOW_LINKS=false ;
				else
					FOLLOW_LINKS=true ;
				fi			
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00006: ERROR:  No argument provided to the -follow parameter."	
				exit 0
			fi				
			;;	
		-debug) OUTPUT_DEBUG=$2 ;
			if [ ! -z "$OUTPUT_DEBUG" ] ; then		

				if [ "$OUTPUT_DEBUG" = "true" ] ; then
					DEBUG="true" ;
				else
					DEBUG="false" ;
				fi			
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00007: ERROR:  No argument provided to the -debug parameter."	
				exit 0
			fi			
			;;	
		-L) LICAGREE=$2
			if [ ! -z "$LICAGREE" ] ; then	
				if [ "$LICAGREE" = "Y" -o "$LICAGREE" = "y" ] ; then
					LICAGREE="YES" ;
				else
					LICAGREE= ;
				fi
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00008: ERROR:  No argument provided to the -L parameter."					
				exit 0
			fi	
			;;
		-p) PRODLIST=$2
			PRODFAMILYLIST=`ls -p ../resources/products/`
	
			if [ -z "$PRODLIST" ] ; then	
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00009: ERROR:  No argument provided to the -p parameter."					
				exit 0
			fi
			
			if [ "$PRODLIST" = "all" ] ;	then
				PRODLIST=`ls ../resources/products/ | grep -v Tuxedo | grep -v FMWRUL`
				PRODUCTSRUN="_all"
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				TMPPLIST="$PRODLIST"
				PRODLIST=
				PRODUCTSRUN=
				for CHOSENPROD in `$ECHO $TMPPLIST | tr ',' ' '`
				do
					$ECHO "$PRODFAMILYLIST" | grep "$CHOSENPROD/" > /dev/null 2>&1
					if [ $? -ne 0 ] ; then
						$ECHO "\n$ARGUSAGE" >&2
						$ECHO "LMSCT: LMS-00010: ERROR:  $CHOSENPROD is not a valid product family."
						exit 0
					fi
					PRODUCTSRUN="${PRODUCTSRUN}_${CHOSENPROD}"
					PRODLIST="$PRODLIST $CHOSENPROD"
				done				

				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			fi				
			;;
		-m) MASK_DATA=$2 ;
			if [ "$MASK_DATA" != "all" -a "$MASK_DATA" != "IP" -a "$MASK_DATA" != "ip" -a "$MASK_DATA" != "user" ] ; then
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00011: ERROR:  Valid option not chosen for the -m mask parameter."
				exit 0
			fi
			
			perl -v 
			if [ $? -ne 0 ] ; then
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00012: ERROR:  Perl was not found in the system path.\nPlease review the documentation for masking requirements."
				exit 0
			fi
			
			perldoc -l Digest::SHA
			if [ $? -ne 0 ] ; then
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00013: ERROR:  Cannot find a perl with Digest::SHA installed.\nPlease review the documentation for masking requirements."
				exit 0
			fi
			
			SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
			shift 2
			;;
		-fastsearch) FASTSEARCH=true
			SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1"
			shift
			;;    
		-tns) REMOTE_DB=YES
			SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1"
			shift
			;;    	
		-r) REMOTEINFO=$2
			REMOTEOPTIONUSED=""
			if [ -f "$REMOTEINFO" ] ; then	
				if [ "$REMOTEOPTIONUSED" = "true" ] ; then
					$ECHO "LMSCT: LMS-00022: ERROR:  Remote option argument cannot be specifed with the remote file and the user\@machine_info on the command line.  Please use one format for remote execution."
					exit 0
				else 
					RUNREMOTE_FILE="true"
					SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
					REMOTEOPTIONUSED="true"
					shift 2
				fi
			else		
				case "$REMOTEINFO" in
				  *\@*) 
						if [ "$REMOTEOPTIONUSED" = "true" ] ; then
							$ECHO "LMSCT: LMS-00022: ERROR:  Remote option argument cannot be specifed with the remote file and the user\@machine_info on the command line.  Please use one format for remote execution."
							exit 0
						fi
						REMOTEOPTIONUSED="true"
					;;
				  *)         
					$ECHO "\n$ARGUSAGE" >&2
					$ECHO "LMSCT: LMS-00014: ERROR:  Remote option argument must be in the form of user\@machine_info or a file containing informataion about multiple remote machines."
					exit 0
				esac
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			fi
			;;  			
		-t) LMSCT_TMP=$2/lmsct_tmp_${MACHINE_NAME}_${LMSCT_PID} ;
			if [ ! -z "$LMSCT_TMP" ] ; then
				if [ ! -d "${LMSCT_TMP}" ] ; then
					mkdir -p "${LMSCT_TMP}" 
				fi			
				if [ ! -w "${LMSCT_TMP}" ] ; then
					$ECHO "\n$ARGUSAGE" >&2
					$ECHO "LMSCT: LMS-00023: ERROR:  User does not have the permission to write to the created subfolder, ${LMSCT_TMP}."						
					exit 0
				fi			
				mkdir -p $LMSCT_TMP/logs
				LMSCT_DEBUG=$LMSCT_TMP/debug
				chmod o+x $LMSCT_TMP
				LMSCT_COLLECTED=$LMSCT_TMP/logs/LMSCT_collected.log
				LMSCT_WARNINGS=$LMSCT_TMP/logs/LMSCT_warnings.log
				LMSCT_ERRORS=$LMSCT_TMP/logs/LMSCT_errors.log
				UNIXCMDERR=$LMSCT_TMP/logs/unixcmderrs.log
				touch $UNIXCMDERR
				SCRIPT_OPTIONS="$SCRIPT_OPTIONS $1 $2"
				shift 2
			else
				$ECHO "\n$ARGUSAGE" >&2
				$ECHO "LMSCT: LMS-00024: ERROR:  No argument provided to the -t parameter."					
				exit 0
			fi				
			;;	
			
		*) $ECHO "\n$ARGUSAGE" >&2
			$ECHO "LMSCT: LMS-00015: ERROR:  "$1" is an invalid entry."
			exit 0
	        ;;
		esac
		
	done
	
	if [ "$REMOTE_DB" = "YES" -a "$LICAGREE" = "YES" ] ; then
		$ECHO "\n$ARGUSAGE" >&2
		$ECHO "LMSCT: LMS-00016: ERROR:  -tns option cannot be used together with silent mode (-L Y)"
		exit 0
	fi 
	
	if [ "$RUNREMOTE_FILE" = "true" -a -n "$PRODLIST" ] ; then
		$ECHO "\n$ARGUSAGE" >&2
		$ECHO "LMSCT: LMS-00017: ERROR:  The -r option with the file argument cannot be used together with the -p option.\nPlease specify the -p option in the remote input file or see instructions for more detail."	
		exit 0
	fi 
	
	
	## Make then see if default directory is writable
	if [ ! -d "${OUTPUT_DIR}" ] ; then
		mkdir -p "${OUTPUT_DIR}" 
	fi	
	
	if [ ! -d "${LMSCT_TMP}" ] ; then
		mkdir -p "${LMSCT_TMP}/logs" 
	fi	

	if [ ! -d "${LMSCT_DEBUG}" ] ; then
		mkdir -p "${LMSCT_DEBUG}" 
	fi	
	
	if [ ! -w "${OUTPUT_DIR}" ] ; then
		$ECHO "\n$ARGUSAGE" >&2
		$ECHO "LMSCT: LMS-00004: ERROR:  User does not have the permission to write to the default output directory, ${OUTPUT_DIR}. Either chmod the correct permissions or chose an output directory via the -o command line arguement."			
		exit 0
	fi	
	
	# set output files
	setOutputFiles
	
	# debug
	$ECHO_DEBUG "\ndebug.function.checkSyntax"
	$ECHO_DEBUG "\ndebug.script options=$SCRIPT_OPTIONS"
	
}

################################################################################
#
# checkNFS - function to check if NFS directories are on the system and if
# the customer is not searching them. 
checkNFS () {

	NFSDIRS=""
	NFSDIRS=`df | grep -i nfs`
	if [ $? -ne 0 ] ; then
		
		if [ -n "$NFSDIRS" -a $SEARCH_NFS != "true" ] ; then
			echo_log "LMSCT: LMS-00110: WARNING: Current system has NFS drives mounted!\nIf you're sure that the Oracle products are installed only on local drives, continue with yes(y), otherwise select No(n) and please run it again with "-fsall true" option.\nRunning the LMS Collection Script on insufficient disks may have a significant impact on the quality of the data and information collected from this environment. Due to this, Oracle LMS may have to get back to you and ask for additional items, or to execute again. " $LMSCT_WARNINGS	
			
			if [ "$LICAGREE" != "YES" ] ; then
				ANSWER=
				while [ -z "${ANSWER}" ]
				do
					$ECHO "\nPlease choose an Y to continue or N to quit:"
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
					echo_log "LMS-00018: ERROR: User chose not to continue the LMSCollection Script." $LMSCT_ERRORS		
					exit 0
				fi
			fi
		fi
	fi



}



################################################################################
#
# credentialValidation - function to check the user running the script and display
# the appropriate messages. 
credentialValidation () {
	# debug
	$ECHO_DEBUG "\ndebug.function.credentialValidation"
	
	# 	use whoami to get user; helps in su and sudo instances; works across platforms.
	#	if whoami not found default to $LOGNAME
        USER_ID_CMD=`type whoami`
		if [ $? -ne 0 ] ; then
			case "${USER_ID_CMD}" in
				*found*)
					if [ "$OS_NAME" = "SunOS" ] ; then
						if [ -x /usr/ucb/whoami ] ; then
								USR_ID=`/usr/ucb/whoami`
						fi
					else
						USR_ID=$LOGNAME
					fi
					;;
				*)
					USR_ID=`whoami`
					;;	
			esac
		else
			USR_ID=`whoami`
		fi


	SCRIPT_USER=$USR_ID
	
	if [ "${SCRIPT_USER}" != "root" ] ; then
		echo_log "LMSCT: LMS-00100: WARNING: Current OS user ${SCRIPT_USER} does NOT have 'administrative' rights!\nIf you're sure that the Current OS user ${SCRIPT_USER} is granted the required privileges, continue with yes(y), otherwise select No(n) and please log on with a OS user with sufficient privileges.\nRunning the LMSCollection Script with insufficient privileges may have a significant impact on the quality of the data and information collected from this environment. Due to this, Oracle LMS may have to get back to you and ask for additional items, or to execute again." $LMSCT_WARNINGS	
		
		if [ "$LICAGREE" != "YES" ] ; then
			ANSWER=
			while [ -z "${ANSWER}" ]
			do
				$ECHO "\nPlease choose an Y to continue or N to quit:"
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
				echo_log "LMS-00018: ERROR: User chose not to continue the LMSCollection Script." $LMSCT_ERRORS		
				exit 0
			fi
		fi
	fi
	

}


################################################################################
#
# debugWarning - function to check if the user understands the debug risk.
#  
debugWarning () {
	# debug
	$ECHO_DEBUG "\ndebug.function.debugWarning"
	
		echo_log "LMSCT: LMS-00200: WARNING: You have chosen to run the LMSCollection tool in debug mode.\n  The script will write data in files in order for Oracle LMS to debug the running of the scripts. You are required to inspect the files for any data that may be sensitive before returning the output to Oracle LMS.  \nIf you wish to continue, continue with yes(y), otherwise select no(n) and contact your LMS representative for more details." $LMSCT_WARNINGS	

		ANSWER=
		while [ -z "${ANSWER}" ]
		do
			$ECHO "\nPlease choose an Y to continue or N to quit:"
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
			echo_log "LMS-00018: ERROR: User chose not to continue the LMSCollection Script." $LMSCT_ERRORS		
			exit 0
		fi
	

}

################################################################################
#
#***********************Portability and Debug Functions************************
#
################################################################################


################################################################################
#
# time stamp
#

setTime() {

	# set time
	NOW="`date '+%m/%d/%Y %H:%M %Z'`"

}

###############################################################
# setAlias
# 
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
	whoami
	"
	 
	path_list="/bin/
	/usr/bin/
	/usr/ucb/"
	 
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
		$ECHO "LMSCT: LMS-00000: ERROR: \n${alias_not_found} utility(ies) not found. Please contact Oracle LMS team." 	
		exit 600
	fi
	#alias
}

##############################################################
# make echo more portable
#

echo_print() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 


################################################################################
#
# expand debug output
#

echo_debug() {
 
	if [ "$DEBUG" = "true" ] ; then
		$ECHO "$*" 
		$ECHO "$*" >> $LMS_DEBUG_FILE
	fi
	
} 

################################################################################
#
# echo_log - allow for logging
#

echo_log() {
 
	$ECHO "$1" 
	$ECHO "$1" >> $2
	
} 

################################################################################
#
# set parameters based on user and hardware
#

setOSSystemInfo() {

	# debug
	$ECHO_DEBUG "\ndebug.function.setOSSystemInfo"

	SCRIPT_SHELL=$SHELL
	TAIL="tail -200"

	# always run ps, ucb/ps, and jps
	
	# check to see if Java Virtual Machine Process Status Tool is available	
	JPSCMD="false"
	JPSCMDFILE=
	JAVA_LOC=`which java 2>>/dev/null` 
	if [ "$?" = "0" -a -f "$JAVA_LOC" ] ; then
		JAVA_DIR=`dirname $JAVA_LOC 2>>$UNIXCMDERR`
		JAVA_SYM=`ls -l $JAVA_LOC | sed 's/.*->\ //g'`
	fi

	if [ -x /usr/java/bin/jps ] ; then
		JPSCMD="true"
		JPSCMDFILE="/usr/java/bin/jps -v"
	elif [ -x $JAVA_DIR/jps ] ; then
		JPSCMD="true"
		JPSCMDFILE="$JAVA_DIR/jps -v"
	else
		JPSCMD="false"
	fi
		
	#setup ucb ps and ps to always run.
	PSCMD_UCB=
	if [ "$OS_NAME" = "SunOS" ] ; then
		PSCMD_UCB="/usr/ucb/ps -auwww"
		PSCMD="ps -eaf"
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		PSCMD_UCB="/usr/ucb/ps -auwww"
		PSCMD="ps -eaf"
	elif [ "$OS_NAME" = "AIX" ] ; then
		PSCMD="ps -eaf"
	elif [ "$OS_NAME" = "Linux" ] ; then
		PSCMD="ps -efww"
	else
		PSCMD="ps -eaf"	
	fi
	
}


################################################################################
#
#***********************License File Detection Utilities************************
#
################################################################################


################################################################################
#
# set results files used for temporary and permanent output
#

setOutputFiles() {

	LMS_FILES=$LMSCT_TMP/logs/LMSfiles.${LMSCT_PID}
	LMS_SORTED_FILES=$LMSCT_TMP/logs/LMSsortedfiles.${LMSCT_PID}
	LMS_MACHINFO_FILE=$LMSCT_TMP/logs/${MACHINE_NAME}-info.txt
	LMS_HOMES_FILE=$LMSCT_TMP/logs/${MACHINE_NAME}-LMS_Homes.txt
	LMS_LOGS_FILE=$LMSCT_TMP/logs/LMSlogfiles.txt
	#files to be collected
	LMS_TAR_FILE_LIST=$LMSCT_TMP/logs/LMStarfilelist.txt
	LMS_RMDATA_FILE_LIST=$LMSCT_TMP/logs/LMSRMDATAfilelist.txt
	
	CMDFILE=$LMSCT_TMP/logs/OraCmdList
	CMDOUTFILE=$LMSCT_TMP/logs/OraCmdOutFileList

	# debug and error files
	LMS_DEBUG_FILE=$LMSCT_TMP/logs/LMSdebugfile.${LMSCT_PID}

	
	# bundled results file
	LMS_TAR_FILE="${OUTPUT_DIR}/LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar"
	export LMS_TAR_FILE

	# results file
	LMS_RESULTS_FILE=$LMSCT_TMP/logs/LMSCollection-${MACHINE_NAME}.txt	
	LMS_ACTIONS_RESULTS_FILE=$LMSCT_TMP/logs/LMSCollection-Actions-${MACHINE_NAME}.txt	
	
	
	$ECHO_DEBUG "\ndebug.function.setOutputFiles"
}
################################################################################
#
# Prompt user for products to be searched the -p option was not passed
# in on the command line.
#

getProducts() {

	# debug
	$ECHO_DEBUG "\ndebug.function.getProductList"
	
	if [ -z "$PRODLIST" ] ; then
	
		$ECHO "\nProduct Families to look for:"
		PRODFAMILYLIST=`ls -p ../resources/products/`
	
		#MENUINCLUDELIST="LMSCPU,OAS,SOA,Tuxedo,WLS"
		for PRODUCT in `ls ../resources/products/`
		do
			case $PRODUCT in
				LMSCPU|OAS|SOA|WLS|DB|EBS|FMW|FormsReports|OBI|Webcenter )
					$ECHO "${PRODUCT}"
					;;
			esac


			#PROD=`grep "ORACLEPRODUCT" ../resources/products/${f} | cut -d'=' -f2`
		done
		$ECHO "all"
		
		PRODUCTSRUN=
		PRODLIST=
		ANSWER=
		INVALID_ANS=
		REMOTE_PROD_OPTS=""
		$ECHO "\nPlease choose an Oracle Product Family from the list above to search for..."
		while [ -z "${ANSWER}" ]
		do
			read PROD
			if [ "${PROD}" = "all" ] ; then 
				PRODLIST=`ls ../resources/products/ | grep -v Tuxedo | grep -v FMWRUL`
				PRODUCTSRUN="_all"
				ANSWER="all"
				REMOTE_PROD_OPTS=",all"
				break
			elif [ "${INVALID_ANS}" != "true" ] ; then
				# Make sure we got a valid Product Family
				TMPPLIST="${PROD}"
				for CHOSENPROD in `$ECHO $TMPPLIST | tr ',' ' '`
				do
					$ECHO "$PRODFAMILYLIST" | grep "$CHOSENPROD/" > /dev/null 2>&1
					if [ $? -ne 0 ] ; then
						echo_log "LMSCT: LMS-00010: ERROR:  $CHOSENPROD is not a valid product family." $LMSCT_ERRORS
						continue
					fi
					PRODUCTSRUN="${PRODUCTSRUN}_${CHOSENPROD}"
					PRODLIST="$PRODLIST $CHOSENPROD"
					REMOTE_PROD_OPTS="${REMOTE_PROD_OPTS},${PROD}"
				done

				$ECHO "Would you like to add another Product? "
			else 
				$ECHO "Invalid answer, please use (y/n). Would you like to add another Product?"
			fi

			$ECHO "[y/n]: \c" >&2
			read ANSWER
			#
			# Act according to the user's response.
			#
			case "${ANSWER}" in
				Y|y) ANSWER=y
					INVALID_ANS=
					;;
				N|n)
					break     # break out of the loop
					;;
				#
				# An invalid choice was entered, reprompt.
				#
				*) ANSWER=
					INVALID_ANS="true"
					;;
			esac

			ANSWER=
			if [ "${INVALID_ANS}"  != "true" ] ; then
				$ECHO "Product Families chosen so far: $PRODLIST"
			fi
		done
	fi
}



##########################################################################################
#
# parse INCLUDPRODUCT tag 
#
parseIncldueProducts() {
	
	$ECHO_DEBUG "Running grep INCLUDEPRODUCT ../resources/products/$1"
	for INCLUDETAG in `grep INCLUDEPRODUCT ../resources/products/${1}`
	do
			$ECHO_DEBUG "Processing INCLUDETAG ${INCLUDETAG}"

			PRODFILE=`$ECHO ${INCLUDETAG} | cut -d'=' -f2`
			case $ALLPRODLIST in
				"${PRODFILE}"* )
					$ECHO_DEBUG "File ${PRODFILE} already added to ALLPRODLIST"
					;;
				*"${PRODFILE}" )
					$ECHO_DEBUG "File ${PRODFILE} already added to ALLPRODLIST"
					;;
				*"${PRODFILE}"* )
					$ECHO_DEBUG "File ${PRODFILE} already added to ALLPRODLIST"
					;;
				* )
					ALLPRODLIST="${ALLPRODLIST} ${PRODFILE}"
					;;
			esac
		for INCLUDETAGS in `grep INCLUDEPRODUCT ../resources/products/${PRODFILE}`
		do	
			parseIncldueProducts ${PRODFILE}
		done	
	done
}

##########################################################################################
#
# parse SEARCHFILE tag and set search files and the action used to identify Oracle product 
# for installations
#
# parse ORACLEPROCESS tag and create a list of process names used to identify Oracle products
#

parseProductFiles() {

	# debug
	$ECHO_DEBUG "\ndebug.function.parseProductFiles"
	ALLSEARCHFILES=""
	PRODUCTLIST=
	RUNLIST=
	CMDOUTFILELIST=
	COMPLETEPRODLIST=
	RUNCPUQ=
	
	# PRODLIST gets set in getProducts()
	# Loop through each directory in PRODLIST and generate a 
	# list(PRODUCTLIST) of individual Products and specific versions 
	
	# Getting a complete list of product product files will be done in 2 passes 
	# the first pass will look for INCLUDEPRODUCT and PREREQUESTIEPRODUCT tags in the 
	# user selected product list
		
	ALLPRODLIST=
	for PRODFAMILY in $PRODLIST
	do

		for RESOURCEFILE in `ls ../resources/products/${PRODFAMILY}`
		do
			$ECHO_DEBUG "Checking RESOURCEFILE ${RESOURCEFILE} for Oracle Product components."

			# make sure ALLPRODLIST is unique
			case $ALLPRODLIST in
				"${RESOURCEFILE}"* )
					$ECHO_DEBUG "File ${RESOURCEFILE} already added to ALLPRODLIST"
					;;
				*"${RESOURCEFILE}" )
					$ECHO_DEBUG "File ${RESOURCEFILE} already added to ALLPRODLIST"
					;;
				*"${RESOURCEFILE}"* )
					$ECHO_DEBUG "File ${RESOURCEFILE} already added to ALLPRODLIST"
					;;
				* )			
					# Add in the the current file we're look at
					if [ -z "$ALLPRODLIST" ] ; then
						ALLPRODLIST="$PRODFAMILY/$RESOURCEFILE"
					else
						$ECHO $ALLPRODLIST | grep "$PRODFAMILY/$RESOURCEFILE"
						if [ $? -eq 0 ] ; then
							# we already got this file in the list so break 
							# and get the next file
							break
						fi	
						ALLPRODLIST="${ALLPRODLIST} $PRODFAMILY/$RESOURCEFILE"
					fi
					parseIncldueProducts $PRODFAMILY/$RESOURCEFILE
					;;
			esac
		done
	done
		
	# Second Pass through a complete set of Product files to get SEARCHFILE, ORACLEPROCESS ...

	for RESOURCEFILE in $ALLPRODLIST
	do
		$ECHO_DEBUG "Checking RESOURCEFILE ${RESOURCEFILE} for Oracle Product components."
		$ECHO_DEBUG "Running command grep ORACLEPRODUCT ../resources/products/${RESOURCEFILE} | cut -d = -f2 "

		PRODUCT=`grep "ORACLEPRODUCT" ../resources/products/${RESOURCEFILE} | cut -d '=' -f2`
					
		# Check if we already got this product accounted from INCLUDEPRODUCT or PREREQUESITEPRODUCT tags
		# if PRODUCTLIST is not set then just add the product to the list
					
		if [ -z "$PRODUCTLIST" ] ; then
			PRODUCTLIST=$PRODUCT
		else

			$ECHO $PRODUCTLIST | grep "$PRODUCT"
			if [ $? -eq 0 ] ; then
				break
			fi
			PRODUCTLIST="$PRODUCTLIST $PRODUCT"
		fi

		for SEARCHNAME in `grep SEARCHFILE ../resources/products/${RESOURCEFILE}`
		do
			# check and see if grep succeeeded
			if [ $? -eq 0 ] 
			then
				FILENAME=`$ECHO ${SEARCHNAME} | cut -d'=' -f2 | cut -d '|' -f1`
				
				# make sure filenames are unique
				case $ALLSEARCHFILES in
					"name ${FILENAME}"* )
						$ECHO_DEBUG "File ${FILENAME} already added to ALLSEARCHFILES"
						;;
					*"name ${FILENAME}" )
						$ECHO_DEBUG "File ${FILENAME} already added to ALLSEARCHFILES"
						;;
					*"name ${FILENAME}"* )
						$ECHO_DEBUG "File ${FILENAME} already added to ALLSEARCHFILES"
						;;
					* )			
						FINDARG="-name"
						
						if [ "$ALLSEARCHFILES" = "" ]
						then
							ALLSEARCHFILES="${FINDARG} ${FILENAME}"
						else
							ALLSEARCHFILES="${ALLSEARCHFILES} -o ${FINDARG} ${FILENAME}"
						fi
						
						#
						# NOTE: if you add a file to the search list please add the appropriate
						# FILE_ACTION in the fileProcess call subroutine
						#
						FILEACTION=`$ECHO ${SEARCHNAME} | cut -d'|' -f2`
						case $FILEACTION in
							BUNDLE )	BUNDLEFILES="$BUNDLEFILES ${FILENAME}" ;;
							TIMESTAMP )	TSFILES="$TSFILES ${FILENAME}" ;;
							TAIL )		TAILFILES="$TAILFILES ${FILENAME}" ;;
							LISTING )	LISTINGFILES="$LISTINGFILES ${FILENAME}" ;;
							COPY )		COPYFILES="$COPYFILES ${FILENAME}" ;;
							LOG )		LOGFILES="$LOGFILES ${FILENAME}" ;;
							COLLECTRMDATA ) COLLECT_RM_DATA_FILES="$COLLECT_RM_DATA_FILES ${FILENAME}" ;;
						esac
						;;
				esac	
			fi
			$ECHO_DEBUG "Processing SEARCHNAME ${SEARCHNAME}"
		done
		
			
		for PROCESSTAG in `grep -i ORACLEPROCESS ../resources/products/${RESOURCEFILE}`
		do
			if [ $? -eq 0 ]
			then
				PROCNAME=`$ECHO ${PROCESSTAG} | cut -d'=' -f2`
						# make sure run command is unique
				case $PROCESSLIST in
					*"${PROCNAME}" )
						$ECHO_DEBUG "${PROCNAME} already added to PROCESSLIST"
						;;
					"${PROCNAME}"* )
						$ECHO_DEBUG "${PROCNAME} already added to PROCESSLIST"
						;;
					*"${PROCNAME}"* )
						$ECHO_DEBUG "${PROCNAME} already added to PROCESSLIST"
						;;
					*)
						PROCESSLIST="${PROCESSLIST} ${PROCNAME}"
						;;
				esac
			fi
			$ECHO_DEBUG "Processing PROCESSTAG ${PROCESSTAG}"			
		done
			
		for CMDNAMETAG in `grep RUNCMD ../resources/products/${RESOURCEFILE}`
		do
			if [ $? -eq 0 ]
			then
				CMDNAME=`$ECHO ${CMDNAMETAG} | cut -d "=" -f2 -`
				CMDNAME_NODOTS=`$ECHO ${CMDNAME} | cut -c11-` 
				# make sure run command is unique
				case $RUNLIST in
					"${CMDNAME}"* )
						$ECHO_DEBUG "Command ${CMDNAME} already added to RUNLIST"
						;;
					*"${CMDNAME}" )
						$ECHO_DEBUG "Command ${CMDNAME} already added to RUNLIST"
						;;
					*"${CMDNAME}"* )
						$ECHO_DEBUG "Command ${CMDNAME} already added to RUNLIST"
						;;
					*"${CMDNAME_NODOTS}"*  )
						$ECHO_DEBUG "Command ${CMDNAME} already added to RUNLIST"
						;;	
					* )
						$ECHO_DEBUG "${CMDNAME}!=${RUNLIST} so adding it."

						#
						# Some of the product files use relative paths, so let's convert those 
						# to absolute paths in order to be sure of the scripts we are running.
						#
						CURRENT_DIR=`pwd -P`
						if [ ! -d `dirname ${CMDNAME}` ] ; then
							mkdir -p `dirname ${CMDNAME}`
						fi
						
						cd `dirname ${CMDNAME}` > /dev/null
						SCRIPTPATH=`pwd -P`
						cd $CURRENT_DIR > /dev/null
						SCRIPTNAME=`basename ${CMDNAME}`
						CMDNAME="${SCRIPTPATH}/${SCRIPTNAME}"
						
						# Run CPUQ before machine info section and rmdata after
						case $CMDNAME in
							*"cpuq_main"*)
								RUNCPUQ="${CMDNAME}:";;
							*"rmdata"*)
								RUNRMDATA="${CMDNAME}:";; 
						esac
					
						
						if [ -z "$RUNLIST"  ] ; then
								RUNLIST="${CMDNAME}:"
						else
								RUNLIST="${RUNLIST}${CMDNAME}:"
						fi
						;;
				esac
			fi
			$ECHO_DEBUG "Processing CMDNAMETAG ${CMDNAMETAG}"			
		done
		
		for CMDOUTFILETAG in `grep CMDOUTFILE ../resources/products/${RESOURCEFILE}`
		do
			if [ $? -eq 0 ]
			then
				CUTFILE=`$ECHO ${CMDOUTFILETAG} | cut -d'=' -f2 | cut -d '|' -f1`
				FILENAME=`eval echo $CUTFILE`
				FILENAME_NODOTS=`$ECHO ${FILENAME} | cut -c12-`
				 
				# make sure command outfile command is unique
				case $CMDOUTFILELIST in
					 *"${FILENAME}" )
						$ECHO_DEBUG "Filename ${FILENAME} already added to CMDOUTFILELIST"
						;;
					 "${FILENAME}"* )
						$ECHO_DEBUG "Filename ${FILENAME} already added to CMDOUTFILELIST"
						;;
					*"${FILENAME}"* )
						$ECHO_DEBUG "Filename ${FILENAME} already added to CMDOUTFILELIST"
						;;
					*"${FILENAME_NODOTS}")
						$ECHO_DEBUG "Command ${CMDNAME} already added to RUNLIST"
						;;							
					* )
						#
						# Some of the product files use relative paths, so let's convert those 
						# to absolute paths in order to be sure of the scripts we are running.
						#
						CURRENT_DIR=`pwd -P`
						if [ ! -d `dirname ${FILENAME}` ] ; then
							mkdir -p `dirname ${FILENAME}`
						fi
						cd `dirname ${FILENAME}` > /dev/null
						SCRIPTPATH=`pwd -P`
						cd $CURRENT_DIR > /dev/null
						SCRIPTNAME=`basename ${FILENAME}`
						FILENAME="${SCRIPTPATH}/${SCRIPTNAME}"

						CMDOUTFILELIST="$CMDOUTFILELIST ${FILENAME}"

						#
						# NOTE: if you add a file to the search list please add the appropriate
						# FILE_ACTION 
						# Currently only supporting BUNDLE and TIMESTAMP for
						# our command file outputs
						FILEACTION=`$ECHO ${CMDOUTFILETAG} | cut -d'|' -f2`
							case $FILEACTION in
								BUNDLE )	BUNDLEFILES="$BUNDLEFILES ${FILENAME}" ;;
								TIMESTAMP )	TSFILES="$TSFILES ${FILENAME}" ;;
							esac
						;;		
				esac
				
			fi
			$ECHO_DEBUG "Processing CMDOUTFILETAG ${CMDOUTFILETAG}"		
		done
		
		for ENVVARSTAG in `grep ENVVARS ../resources/products/${RESOURCEFILE}`
		do
			if [ $? -eq 0 ]
			then
				CUTENV=`$ECHO ${ENVVARSTAG} |  cut -d'=' -f2`
				
				# make sure env var is unique
				case $ENVVARSLIST in
					 *"${CUTENV}" )
						$ECHO_DEBUG "Env Var ${CUTENV} already added to ENVVARSLIST"
						;;
					 "${CUTENV}"* )
						$ECHO_DEBUG "Env Var  ${CUTENV} already added to ENVVARSLIST"
						;;
					*"${CUTENV}"* )
						$ECHO_DEBUG "Env Var  ${CUTENV} already added to ENVVARSLIST"
						;;
								
					* )
						
						ENVVARSLIST="$ENVVARSLIST ${CUTENV}"
				esac
				
			fi
			$ECHO_DEBUG "Processing ENVVARSTAG ${ENVVARSTAG}"		
		done
		
		for PROCARGSTAG in `grep PROCARGS ../resources/products/${RESOURCEFILE}`
		do
			if [ $? -eq 0 ]
			then
				CUTPROCS=`$ECHO ${PROCARGSTAG} |  cut -d'=' -f2`
								 
				# make sure proc arg is unique
				case $PROCARGSLIST in
					 *"${CUTPROCS}" )
						$ECHO_DEBUG "Process Argument ${CUTPROCS} already added to PROCARGSLIST"
						;;
					 "${CUTPROCS}"* )
						$ECHO_DEBUG "Process Argument ${CUTPROCS} already added to PROCARGSLIST"
						;;
					*"${CUTPROCS}"* )
						$ECHO_DEBUG "Process Argument ${CUTPROCS} already added to PROCARGSLIST"
						;;				
					* )
						PROCARGSLIST="$PROCARGSLIST ${CUTPROCS}"
				esac
				
			fi
			$ECHO_DEBUG "Processing PROCARGSTAG ${PROCARGSTAG}"		
		done
				
	done
	
	$ECHO "\nProduct Name discovery list: $PRODUCTLIST\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "All Product files used: $ALLPRODLIST\n"  >> $LMS_ACTIONS_RESULTS_FILE
	
	$ECHO "Files to be bundled: $BUNDLEFILES\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Files to be collected and sensitive data removed: $COLLECT_RM_DATA_FILES\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Search files: $ALLSEARCHFILES\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Oracle processes: $PROCESSLIST\n" >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Commands to be run: $RUNLIST\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Command Output Files: $CMDOUTFILELIST\n"  >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Environment Variables: $ENVVARSLIST\n" >> $LMS_ACTIONS_RESULTS_FILE
	$ECHO "Process arguments: $PROCARGSLIST\n" >> $LMS_ACTIONS_RESULTS_FILE


}



################################################################################
#
# setup search options: directory and product and if there is no 
# command line arguments, set defaults
#

setSearchOptions() {

	# debug
	$ECHO_DEBUG "\ndebug.function.setSearchOptions"

	# default search options
	SEARCH_EXCLUSIONS=
	SEARCH_OPTIONS=
	SEARCH_LOG_FILES=
	FS_EXCLUDE_NFS="-fstype nfs"
	PRUNE="-prune"
	PRINT="-print"
	FOLLOW="-follow"
	
	# exclude nfs search if requested
	if [ "$SEARCH_NFS" = "true" ] ; then
		FS_EXCLUDE_NFS=
	else
		if [ "$OS_NAME" = "SunOS" ] ; then
			FS_EXCLUDE_NFS="! -local"
		fi
	fi

	# exclude follow if requested
	if [ "$FOLLOW_LINKS" = "false" ] ; then
		FOLLOW=
	fi


	
	#
	# setup os based search exclusions variable SEARCH_EXCLUSIONS
	#
	if [ "$OS_NAME" = "Linux" ] ; then
		FS_EXCLUDES="-fstype proc -o -fstype sysfs"
	elif [ "$OS_NAME" = "SunOS" ] ; then
		FS_EXCLUDES="-fstype proc -o -fstype fd"
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		FS_EXCLUDES=
	elif [ "$OS_NAME" = "AIX" ] ; then
		FS_EXCLUDES=
	fi

	if [ -n "$FS_EXCLUDE_NFS" ] ; then		
		if [ -n "$FS_EXCLUDES" ] ; then 		
			SEARCH_EXCLUSIONS="$FS_EXCLUDE_NFS -o $FS_EXCLUDES"
		else
			SEARCH_EXCLUSIONS="$FS_EXCLUDE_NFS"
		fi
	else
		if [ -n "$FS_EXCLUDES" ] ; then 		
			SEARCH_EXCLUSIONS="$FS_EXCLUDES"
		fi
	fi

    #
	# setup os based search options variable SEARCH_OPTIONS
	#
	if [ "$OS_NAME" = "Linux" ] ; then
		SEARCH_OPTIONS="$FOLLOW $PRINT"
	elif [ "$OS_NAME" = "SunOS" ] ; then
		SEARCH_OPTIONS="$FOLLOW $PRINT"
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		SEARCH_OPTIONS="$FOLLOW $PRINT"
	elif [ "$OS_NAME" = "AIX" ] ; then
		#exclude follow option, since it is not supported on all AIX versions
		SEARCH_OPTIONS="$PRINT"
	fi
	
	#
	# setup fast search directories if FASTSEARCH=true
	#
	if [ "$FASTSEARCH" = "true" ] ; then
		SEARCH_DIR=
	
		while read LINE
		do
			SEARCH_DIR="${SEARCH_DIR} ${LINE}"
		done < $LMS_HOMES_FILE
	fi

}

################################################################################
#
# set default search directories using running oracle process and 
# any bea/beahomeslist files found in USER HOMES directories.
#
getDefaultOracleEnv() {
	# debug
	$ECHO_DEBUG "\ndebug.function.getDefaultOracleEnv"

	# check running processes for java command line get info from printMachineInfo run

	LMSAWK=awk
	if [ "$OS_NAME" = "SunOS" ] ; then
		LMSAWK=nawk
	fi
	 
	
	for JAVAPROCESSLINE_TOKENS in `grep java ${LMS_MACHINFO_FILE} | $LMSAWK -F":| " -v OFS="\n" '$1=$1' `
	do
		case "$JAVAPROCESSLINE_TOKENS" in 
		*weblogic.jar*)
			echo $JAVAPROCESSLINE_TOKENS | awk -F'/' '{for (i=1; i<NF-3; i++) printf("%s/", $i)}' >> $LMS_HOMES_FILE
			;;
		*.home=*)
			echo $JAVAPROCESSLINE_TOKENS | sed -e 's/.*.home=\(\S*\).*/\1/g' >> $LMS_HOMES_FILE
			;;
		*_HOME=*)
			echo $JAVAPROCESSLINE_TOKENS | sed -e 's/.*._HOME=\(\S*\).*/\1/g' >> $LMS_HOMES_FILE
			;;
		esac
	done

	$ECHO_DEBUG "\ndebug.getDefaultOracleEnv.JAVAPROCESSLINE_TOKENS=${JAVAPROCESSLINE_TOKENS}"
	# check environment variables for specified directories
	#Get java pids
	JAVAPIDS=`grep java ${LMS_MACHINFO_FILE} | awk '{print $5}'`
	$ECHO_DEBUG "\ndebug.getDefaultOracleEnv.JAVAPIDS=$JAVAPIDS"
	# Normalize ENVVARSLIST for grep.
	ENVGREPLIST=`echo $ENVVARSLIST | sed -e 's/ /\\\|/g'`
	$ECHO_DEBUG "\ndebug.getDefaultOracleEnv.ENVVARSLIST=$ENVVARSLIST"

	for PID in $JAVAPIDS
	do
		case $PID in
		   *[!0-9]*|'')
				 ;; # not a number
			*)
				if [ "$OS_NAME" = "SunOS" ] ; then
						pargs -e $PID | grep $ENVGREPLIST  >> $LMS_HOMES_FILE
				elif [ "$OS_NAME" = "AIX" ] ; then
						ps eauwww $PID | grep $ENVGREPLIST >> $LMS_HOMES_FILE
				elif [ "$OS_NAME" = "Linux" ] ; then
						strings /proc/${PID}/environ | grep $ENVGREPLIST  >> $LMS_HOMES_FILE
				fi
				;;
		esac

	done

	# check user homes for bea/beahomeslist
	# need to research way to check NIS dirs
	LOCALHOMES=`awk -F":" '{ print $6 }' /etc/passwd | sort | uniq`
	for USERHOME in $LOCALHOMES
	do
		if [ -f ${USERHOME}/bea/beahomelist ] ; then
			cat ${USERHOME}/bea/beahomelist | tr ';' '\n'  >> $LMS_HOMES_FILE
			echo '
			'  >> $LMS_HOMES_FILE
		fi
	done

	# Pair down LMS_HOMES_FILE
	if [ -f $LMS_HOMES_FILE ] ; then
		sed 's/user_projects*/ /g' $LMS_HOMES_FILE > $LMS_HOMES_FILE.tmp && mv $LMS_HOMES_FILE.tmp $LMS_HOMES_FILE
		sed 's/wlserver*/ /g' $LMS_HOMES_FILE > $LMS_HOMES_FILE.tmp && mv $LMS_HOMES_FILE.tmp $LMS_HOMES_FILE

		cat $LMS_HOMES_FILE | sed -e 's/.*.weblogic\.jar\(\S*\).*/\1/g' -e 's/.*.home=\(\S*\).*/\1/g' -e 's/.*._HOME=\(\S*\).*/\1/g' | uniq > $LMS_HOMES_FILE.tmp
		mv $LMS_HOMES_FILE.tmp $LMS_HOMES_FILE
	fi
}
################################################################################
#
# spinner to show process  is running
#
spinner() {
	#Determine if running in background or not for spinner display
	pid=$! # Process Id of the previous running command
	case $RUNNING_STATUS in
		*\+*) 
			#Running in foreground; use spinner
			while kill -0 $pid 2>/dev/null
			do
			  for s in / - \\ \|; do
				printf "\r$s"
				sleep 1
			  done
			done
			;;
		*)
			while kill -0 $pid 2>/dev/null
			do
				sleep 1
			done
			;;
	esac	
		

}


################################################################################
#
# function to search desired files
#

doSearch() {
	
	# debug
	$ECHO_DEBUG "\ndebug.function.doSearch"

	# echo search criteria - debug
	$ECHO_DEBUG "\ndebug.search.directory=${SEARCH_DIR}"
	$ECHO_DEBUG "\ndebug.search.options.exclusions=$SEARCH_EXCLUSIONS"
	$ECHO_DEBUG "\ndebug.search.files=$ALLSEARCHFILES"
	$ECHO_DEBUG "\ndebug.search.options=$SEARCH_OPTIONS"
	

	# if no exclusions are defined then eliminate from find call
	if [ -n "$SEARCH_EXCLUSIONS" ] ; then
		SEARCH_COMMAND="find ${SEARCH_DIR} \( ${SEARCH_EXCLUSIONS} \) ${PRUNE} -o \( ${ALLSEARCHFILES} \) ${SEARCH_OPTIONS} >> ${LMS_FILES} 2>>$UNIXCMDERR"
		$ECHO_DEBUG "debug.search.command=$SEARCH_COMMAND"
		find ${SEARCH_DIR} \( ${SEARCH_EXCLUSIONS} \) ${PRUNE} -o \( ${ALLSEARCHFILES} \) ${SEARCH_OPTIONS} >> ${LMS_FILES} 2>>$UNIXCMDERR &
		spinner
	else
		SEARCH_COMMAND="find ${SEARCH_DIR} \( $ALLSEARCHFILES \) $SEARCH_OPTIONS"
		$ECHO_DEBUG "debug.search.command=$SEARCH_COMMAND"
		find ${SEARCH_DIR} \( ${ALLSEARCHFILES} \) ${SEARCH_OPTIONS} >> ${LMS_FILES} 2>>$UNIXCMDERR &
		spinner
	fi
}


################################################################################
#
# function to execute desired shell script or command
#

doRunCmd() {

CMDLIST=$1

FLDNUM=1
		
	while true
	do
		CMDLINE=`$ECHO $CMDLIST | cut -d ':' -f${FLDNUM}`
		
		# No more commands to execute
		if [ "$CMDLINE" = "" ] ; then
			break
		fi
		
		CMD=`$ECHO $CMDLINE | cut -d '|' -f1`
		CMDTYPE=`$ECHO $CMDLINE | cut -d '|' -f2`
		
		
		if [ "$CMDTYPE" = "SCRIPT" ] ; then
			#Add .sh extension for Unix/Linux on Windows we'll add .cmd
			CMD="$CMD.sh"
		fi
		
		if [ "$CMD" = ".sh" ] ; then
			# Only found the .sh extension
			break
		fi
		# check if the script or command exists
		if [ -f "$CMD" ]; then
			# Make sure the script is executable
			$ECHO "\nTesting script availability and executability\n"
			if [ ! -x $CMD ] ; then
			
				chmod +x $CMD
				$ECHO "\nchmod +x on $CMD script\n"
				if [ ! -x $CMD ]; then
					echo_log "LMSCT: LMS-00019: ERROR:  The script, $CMD, is not executable, and the current user is unable to change permissions.\nPlease change persmisions on $CMD to be executable and re-run the script.\n" $LMSCT_ERRORS
					FLDNUM=`expr ${FLDNUM} + 1`
					continue
				fi
			fi


			case $CMD in
				*cpuq_main.sh) 
					if [ "$RANCPUQ"  = "false" ] ; then
						$ECHO "Executing $CMD\n"
						eval $CMD >/dev/null 2>&1 
					fi
					;;
				*rmdata.sh) 
					if [ "$OKTORUNRMDATA"  = "true" ] ; then
						$ECHO "Executing $CMD\n"
						eval $CMD >/dev/null 2>&1 
					fi
					;;
				*) 
					$ECHO "Executing $CMD\n"
					eval $CMD
					;;
			esac
		else
		
			# it must be a Unix/Linux command or pipeline of commands
			$ECHO "Executing $CMD\n"
			case $CMD in
			  *cpuq_main.sh) 
					if [ "$RANCPUQ"  = "false" ] ; then
						$ECHO "Executing $CMD\n"
						eval $CMD >/dev/null 2>&1
					fi
					;;
				*rmdata.sh) 
					if [ "$OKTORUNRMDATA"  = "true" ] ; then
						$ECHO "Executing $CMD\n"
						eval $CMD >/dev/null 2>&1 
					fi
					;;
				*) 
					$ECHO "Executing $CMD\n"
					eval $CMD "$@"
					;;
			esac
			if [ $? -ne 0 ] ; then
				echo_log "$CMD failed to execute error $?\n" $UNIXCMDERR
				
				if [ -f "$CMD" ] ; then
					# it could be a missing shell script
					echo_log "Shell Script $CMD not found.\nPlease copy all files from distribution into the correct directories.\n" $UNIXCMDERR
				else
					# Unknown error
					echo_log "$CMD Unknown error" $UNIXCMDERR					
				fi
			fi
		fi
		FLDNUM=`expr ${FLDNUM} + 1`
		$ECHO "\n$CMD ran without errors." >> $LMS_ACTIONS_RESULTS_FILE
		
	done

}


################################################################################
#
# function to change the sort files and avoid duplication 
#

fileSort() {

	# debug
	$ECHO_DEBUG "\ndebug.function.fileSort"
	LMS_SORTED_FILES_TMP=$LMS_SORTED_FILES.tmp
	NUMSORTFILE=0  
	# test to see if grep -v is on system
	grep -v -f ../resources/util/file_sort_list_unix.txt ../resources/util/file_sort_list_unix.txt >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		 grep -v -f ../resources/util/file_sort_list_unix.txt $LMS_FILES > $LMS_SORTED_FILES_TMP
	else
		/usr/xpg4/bin/grep -v -f ../resources/util/file_sort_list_unix.txt ../resources/util/file_sort_list_unix.txt >/dev/null 2>&1
		if [ $? -eq 0 ] ;
		then
			/usr/xpg4/bin/grep -v -f ../resources/util/file_sort_list_unix.txt $LMS_FILES > $LMS_SORTED_FILES_TMP
		else
			cp $LMS_FILES $LMS_SORTED_FILES_TMP
		fi
	fi
	
	# find unique list of files
	#sort -u $LMS_SORTED_FILES_TMP > $LMS_SORTED_FILES 
	cp $LMS_SORTED_FILES_TMP $LMS_SORTED_FILES
	NUMSORTFILE="`wc -l < $LMS_SORTED_FILES`"
	rm $LMS_SORTED_FILES_TMP
	
	# debug
	$ECHO_DEBUG "\ndebug.sorted.file.number=$NUMSORTFILE"
	
	$ECHO "Sorted Files=$NUMSORTFILE" >> $LMS_RESULTS_FILE	
			
}

################################################################################
#
# function to add any command or script generated output files to the
# list of files we need information for
#
addOutputFiles() {

	# debug
	$ECHO_DEBUG "\ndebug.function.addOutputFiles"
	
	if [ "$CMDOUTFILELIST" != "" ] ; then
		for F in `echo $CMDOUTFILELIST`
		do
			echo $F >> $1
		done
	fi
}

################################################################################
#
# function to change the sort files and avoid duplication 
#

fileGetLMSFiles() {

	LMS_ONLY_FILES=$LMSCT_TMP/logs/LMSonlyfiles.txt
	# debug
	$ECHO_DEBUG "\ndebug.function.fileGetLMSFiles"
	NUMSORTFILE=0

	
	if [ "$OS_NAME" = "Linux" ] ; then
		OLD_IFS=$IFS
		IFS='
		'
	fi
	
	while read FULL_PATH_FILE_NAME
	do
		FILE_NAME=`basename "$FULL_PATH_FILE_NAME"`
		if [ "$FILE_NAME" = "config.xml" ];
		then
			# Get rid of non-Weblogic config files
			grep -i "<domain" "$FULL_PATH_FILE_NAME" >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES
			fi
		elif [ "$FILE_NAME" = "registry.xml" ];
		then
			# Get rid of non-Weblogic config files
			grep "product-information" "$FULL_PATH_FILE_NAME" >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES
			fi
		elif [ "$FILE_NAME" = "server.xml" ];
		then
			# Get rid of non-OAS server files
			echo "$FULL_PATH_FILE_NAME" | grep j2ee >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES
			fi
		elif [ "$FILE_NAME" = "app.yml" ];
		then
			# Get rid of non-WebCenter Mobility app.yml files
			echo "$FULL_PATH_FILE_NAME" | grep "msadmin\|mobilityserver" >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES
			fi		
		elif [ "$FILE_NAME" = "config.cfg" ];
		then
			echo "$FULL_PATH_FILE_NAME" | grep "ucm" >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				# check for only WebCenter UCM Config.cfg files.
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES	
			fi
		elif [ -d "$FULL_PATH_FILE_NAME" ];
		then
			echo "$FULL_PATH_FILE_NAME" | grep "bin/output" >/dev/null 2>&1
			if [ $? -eq 0 ] ;
			then
				# Get rid of just directories that are not in ./bin/output
				echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES	
			fi
		else
			# Not a config.xml,server.xml, registry.xml or directory so we don't
			# need to  check for WebLogic or Oracle
			echo "$FULL_PATH_FILE_NAME" >> $LMS_ONLY_FILES	
		fi
	done < $LMS_SORTED_FILES
	
	if [ "$OS_NAME" = "Linux" ] ; then
		IFS=$OLD_IFS
	fi

	cmp -s $LMS_ONLY_FILES $LMS_SORTED_FILES
	if [ $? -ne 0 ] ; then
		cp $LMS_ONLY_FILES $LMS_SORTED_FILES 2>>$UNIXCMDERR
	fi
	
	
	
	NUMSORTFILE="`wc -l < $LMS_SORTED_FILES`" 2>>$UNIXCMDERR

	rm -f $LMS_ONLY_FILES

	# debug
	
	$ECHO "Sorted Oracle only Files=$NUMSORTFILE" >> $LMS_RESULTS_FILE	
			
}

################################################################################
#
# function to remove non-WebLogic config.xml files
#

################################################################################
#
# function to copy files to output 
#

fileCopy() {

	# debug
	$ECHO_DEBUG "debug.function.fileCopy"
	$ECHO_DEBUG "debug.processing.file$2.copy=$1"
		
	# obtain timestamp for all copied files
	fileTimestamp $1 $2
		
	$ECHO "processing.file$2.copy.data=" >> $LMS_RESULTS_FILE
	$ECHO "[COPY_$TAG_BEGIN]" >> $LMS_RESULTS_FILE
	
	# post command to results file
	cat $1 >> $LMS_RESULTS_FILE 2>>$UNIXCMDERR	

	$ECHO "\n[COPY_$TAG_END]" >> $LMS_RESULTS_FILE
	
}


################################################################################
#
# function to get a files tail to output 
#

fileTail() {

	# debug
	$ECHO_DEBUG "debug.function.fileTail"
	$ECHO_DEBUG "debug.processing.file$2.tail=$1"
		
	$ECHO "Processing file:$1" >> $LMS_LOGS_FILE
	$ECHO "[TAIL_$TAG_BEGIN]" >> $LMS_LOGS_FILE

	if [ -s $1 ]; then
	
		# post command to results file
		$TAIL $1 >> $LMS_LOGS_FILE 2>>$UNIXCMDERR	
	else
		$ECHO "Log file is empty" >> $LMS_LOGS_FILE 2>>$UNIXCMDERR	
	fi

	$ECHO "\n[TAIL_$TAG_END]\n" >> $LMS_LOGS_FILE
}


################################################################################
#
# function to get a files timestamp to output 
#

fileTimestamp() {

	# debug
	$ECHO_DEBUG "debug.function.fileTimestamp"
	$ECHO_DEBUG "debug.processing.file$2.timestamp=$1"
	
	$ECHO "processing.file$2.timestamp.data=" >> $LMS_RESULTS_FILE
	$ECHO "[TIMESTAMP_$TAG_BEGIN]" >> $LMS_RESULTS_FILE
	
	# post command to results file
	ls -la $1 >> $LMS_RESULTS_FILE 2>>$UNIXCMDERR	

	$ECHO "[TIMESTAMP_$TAG_END]" >> $LMS_RESULTS_FILE
}


################################################################################
#
# function to get a files directory listing to output 
#

fileListing() {

	# debug
	$ECHO_DEBUG "debug.function.fileListing"
	$ECHO_DEBUG "debug.processing.file$2.listing=$1"
	
	DIR_NAME=`dirname $1` 2>>$UNIXCMDERR
		
	$ECHO "processing.file$2.listing.data=" >> $LMS_RESULTS_FILE
	$ECHO "[LISTING_$TAG_BEGIN]" >> $LMS_RESULTS_FILE
	
	# post command to results file
	ls -la $DIR_NAME >> $LMS_RESULTS_FILE 2>>$UNIXCMDERR	
	
	$ECHO "[LISTING_$TAG_END]" >> $LMS_RESULTS_FILE
}

################################################################################
#
# function to copy files to output 
#

bundleResults() {

	# debug
	$ECHO_DEBUG "debug.function.bundleResults"
	chmod 700 $LMSCT_TMP/FMW
	
	if [ -f $LMS_TAR_FILE_LIST ] ; then
		pax -rw < $LMS_TAR_FILE_LIST $LMSCT_TMP/FMW/ 2>>$UNIXCMDERR
		if [ $? -ne 0 ] ; then
			while read -r file
			do 
				tmpdirname=`dirname $file`
				mkdir -p $LMSCT_TMP/FMW/$tmpdirname
				cp $file $LMSCT_TMP/FMW/$tmpdirname/.
			done < $LMS_TAR_FILE_LIST
		fi
	fi
	
	if [ -f $LMS_RMDATA_FILE_LIST ] ; then
		pax -rw < $LMS_RMDATA_FILE_LIST $LMSCT_TMP/FMW/ 2>>$UNIXCMDERR
		if [ $? -ne 0 ] ; then
			while read -r file
			do 
				tmpdirname=`dirname $file`
				mkdir -p $LMSCT_TMP/FMW/$tmpdirname
				cp $file $LMSCT_TMP/FMW/$tmpdirname/.
			done < $LMS_RMDATA_FILE_LIST
		fi
		
		mv $LMS_RMDATA_FILE_LIST $LMS_RMDATA_FILE_LIST.bak
	
		old_IFS=$IFS      # save the field separator           
		IFS='
		'     
		# new field separator, the end of line 

		for file in `cat $LMS_RMDATA_FILE_LIST.bak`
		do
			echo "$LMSCT_TMP/FMW$file" >> $LMSCT_TMP/logs/LMSRMDATACopiesfilelist.txt
		done
		IFS=$old_IFS     # restore default field separator 
	fi
	
}

################################################################################
#
# function to copy files in ./bin/output to output 
#

bundleLMSOutput() {
	# debug
	OUTPUT_UNIXCMDERRS=$LMSCT_DEBUG/unixcmderrs.log
	
	WORKINGDIR=`pwd`
	cd $LMSCT_TMP
	for DIRS in * ; do
		if [ "$DIRS" != "debug" ] ; then
			if [ -d $DIRS ] ; then
				EMPTYDIR=`ls -A $DIRS`
				if [ "$EMPTYDIR" = "" ] ; then
					rm -rf $DIRS
				else 
					if [ -s $LMS_TAR_FILE ] ; then
						ACTION=u
					else
						# tar file does not exist so create it
						ACTION=c
					fi				
					tar ${ACTION}f $LMS_TAR_FILE $DIRS 2>>$OUTPUT_UNIXCMDERRS
				fi
			fi
		else 
			if [ "$COLLECT_LMS_DEBUG" = "true" ] ; then
				if [ -d $DIRS ] ; then
					cd $DIRS
					# check if compressed archive file exists, if so move older one.
					if [ -f $LMS_DEBUG_TAR_FILE.bz2 ] ; then
						mv $LMS_DEBUG_TAR_FILE.bz2 $LMS_DEBUG_TAR_FILE.bz2.$TARTIMESTAMP
					fi
					if [ -f $LMS_DEBUG_TAR_FILE.Z ] ; then
						mv $LMS_DEBUG_TAR_FILE.Z $LMS_DEBUG_TAR_FILE.Z.$TARTIMESTAMP
					fi
						
					tar cf $LMS_DEBUG_TAR_FILE * 2>>$OUTPUT_UNIXCMDERRS
					bzip2 $LMS_DEBUG_TAR_FILE 2>>$UNIXCMDERR
					if [ ${?} -ne 0 ] ; then
						compress $LMS_DEBUG_TAR_FILE 2>>$UNIXCMDERR
						if [ ${?} -ne 0 ] ; then
							echo_log "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LMS_DEBUG_TAR_FILE" $LMSCT_WARNINGS	
						else
							rm $LMS_DEBUG_TAR_FILE
							echo_log "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LMS_DEBUG_TAR_FILE.Z" $LMSCT_WARNINGS	
						fi
					else
						echo_log "LMSCT: LMS-00040: WARNING: Please note that for debugging purposes the following archive file was created in the output folder: $LMS_DEBUG_TAR_FILE.bz2" $LMSCT_WARNINGS	
					fi
					cd ..
				fi
			fi
		fi
	done
	
	cd $WORKINGDIR

}



################################################################################
#
# function used to process file data to results file
#

fileAction() {

	NUMPROCESSFILE=0
	while read FILE_NAME
	do 
		PROCESS_FILE_NAME="$FILE_NAME"
		PRODUCT_FILE_BASENAME=`basename "$PROCESS_FILE_NAME"` 2>>$UNIXCMDERR
		
		NUMPROCESSFILE=`expr ${NUMPROCESSFILE} + 1`
		$ECHO "Processing file $NUMPROCESSFILE path="$PROCESS_FILE_NAME"" >> $LMS_RESULTS_FILE	
		$ECHO "Processing file $NUMPROCESSFILE name=$PRODUCT_FILE_BASENAME" >> $LMS_RESULTS_FILE
		
		FILE_PROCESSED=
		
		for BUNDLE_FILE in `$ECHO $BUNDLEFILES`
		do
		
			case $PRODUCT_FILE_BASENAME in
				$BUNDLE_FILE)	$ECHO "$FILE_NAME" >> $LMS_TAR_FILE_LIST 
				$ECHO "Tar up $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
			
			# Check for full path for our CMDOUTFILEs	
			case $FILE_NAME in
				$BUNDLE_FILE)	$ECHO "$FILE_NAME" >> $LMS_TAR_FILE_LIST
				$ECHO "Tar up $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
				
			esac
		done
		
		#performed the above action so get the next file
		if [ "$FILE_PROCESSED" = "TRUE" ] ; then
			continue
		fi
		
		for RMDATA_FILE in `$ECHO $COLLECT_RM_DATA_FILES`
		do
		
			case $PRODUCT_FILE_BASENAME in
				$RMDATA_FILE)	$ECHO "$FILE_NAME" >> $LMS_RMDATA_FILE_LIST 
				$ECHO "Tar up $FILE_NAME and removed sensitve data." >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
			
		done
		
		#performed the above action so get the next file
		if [ "$FILE_PROCESSED" = "TRUE" ] ; then
			continue
		fi
				
		
		
		for TS_FILE in `$ECHO $TSFILES`
		do
			case $PRODUCT_FILE_BASENAME in
				$TS_FILE)	fileTimestamp $FILE_NAME $NUMPROCESSFILE
				$ECHO "Getting Timestamp for $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
		done
		
		#performed the above action so get the next file
		if [ "$FILE_PROCESSED" = "TRUE" ] ; then
					continue
		fi
		
		for TAIL_FILE in `$ECHO $TAILFILES`
		do
			case $PRODUCT_FILE_BASENAME in
				$TAIL_FILE)	fileTail $FILE_NAME $NUMPROCESSFILE
				$ECHO "Tail $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
		done
		
		#performed the above action so get the next file
		if [ "$FILE_PROCESSED" = "TRUE" ] ; then
			continue
		fi
		
		for LIST_FILE in `$ECHO $LISTINGFILES`
		do
			case $PRODUCT_FILE_BASENAME in
				$LIST_FILE)	fileListing $FILE_NAME $NUMPROCESSFILE
				$ECHO "Listing directory $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
		done
		
		#performed the above action so get the next file
		if [ "$FILE_PROCESSED" = "TRUE" ] ; then
			continue
		fi
		
		for COPY_FILE in `$ECHO $COPYFILES`
		do
			case $PRODUCT_FILE_BASENAME in
				$COPY_FILE)	fileCopy $FILE_NAME $NUMPROCESSFILE
				$ECHO "Copying file $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
				FILE_PROCESSED=TRUE
				break
				;;
			esac
		done
		
		for LOG_FILE in `$ECHO $LOGFILES`
		do
			case $PRODUCT_FILE_BASENAME in
				$LOG_FILE)							
				if [ ${LOG_FILE_FLAG} = "true" ] ; then
					$ECHO "$FILE_NAME" >> $LMS_TAR_FILE_LIST
					$ECHO "Tar up $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE	 
				else
					fileTimestamp $FILE_NAME $NUMPROCESSFILE
					$ECHO "Getting Timestamp for $FILE_NAME" >> $LMS_ACTIONS_RESULTS_FILE
	
				fi
				FILE_PROCESSED=TRUE
				break
				;;
				esac
		done

	done < $LMS_SORTED_FILES

}




################################################################################
#
#***************************License Data Output*****************************
#
################################################################################


################################################################################
#
# output welcome message.
#

beginMsg()
{
	

more ../resources/util/license_agreement.txt

ANSWER=

$ECHO "Accept License Agreement? "
	while [ -z "${ANSWER}" ]
	do
		$ECHO "$1 [y/n]: \c" >&2
  	read ANSWER
		#
		# Act according to the user's response.
		#
		case "${ANSWER}" in
			Y|y)
				return 0     # TRUE
				;;
			N|n)
				echo_log "LMSCT: LMS-00019: ERROR: You must accept the license agreement to continue." $LMSCT_ERRORS
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
# print out the search header
#

printMachineInfo() {
	
	NUMIPADDR=0
	DRIVECMD=""
	## set up df to get a list of available drives, try to get type
	if [ "$OS_NAME" = "SunOS" ] ; then
		DRIVECMD="df -n"
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		DRIVECMD="df -n"
	elif [ "$OS_NAME" = "Linux" ] ; then
		DRIVECMD="df -T"
	else
		DRIVECMD="df"
	fi
	# print script information
	$ECHO "[BEGIN SCRIPT INFO]"
	$ECHO "Script Name=$SCRIPT_NAME"
	$ECHO "Script Version=$SCRIPT_VERSION"
	$ECHO "Script Command options=$SCRIPT_OPTIONS"
	$ECHO "Script Command shell=$SCRIPT_SHELL"
	$ECHO "Script Command user=$SCRIPT_USER"
	$ECHO "Available Drives and types="
	$DRIVECMD
	$ECHO "Script Filter File options="
	cat ../resources/util/file_sort_list_unix.txt
	$ECHO "[END SCRIPT INFO]"

	# look for running Oracle processes
	# PROCESSLIST gets set in parseProductFiles()
	
	PROCNUM=0

	$ECHO "[BEGIN ORACLE PROCESS INFO]"
	$ECHO_DEBUG "PROCESSLIST in the process info section: ${PROCESSLIST}"
	for PROC in `$ECHO $PROCESSLIST`
	do
		
		PROCCUT=`$ECHO $PROC | cut -d '|' -f1`
		# NEED TO ADD LOGIC TO HANDLE PARSE command action
		PLINE=`$PSCMD | grep $PROCCUT | grep -v grep |grep -v awk | awk '{print $0} END {if (NR == 0) exit 1 }'`
		# check if awk printed a process line
		if [ $? -eq 1 ] ; then
			$ECHO "$PROCCUT process not running.\n"
		else
			PROCNUM=`expr ${PROCNUM} + 1`
			TEMPPLINE=`echo ${PLINE} | sed -f "../resources/util/common/bin/rmdata.sed"`
			$ECHO "Process# ${PROCNUM} : ${TEMPPLINE}\n"
		fi
		
		PLINE_UCB=`$PSCMD_UCB | grep $PROCCUT | grep -v grep |grep -v awk | awk '{print $0} END {if (NR == 0) exit 1 }'`
		# check if awk printed a process line
		if [ $? -eq 1 ] ; then
			$ECHO "$PROCCUT process not running.\n"
		else
			TEMPPLINE_UCB=`echo ${TEMPPLINE_UCB} | sed -f "../resources/util/common/bin/rmdata.sed"`

			$ECHO "Process# ${PROCNUM} : ${TEMPPLINE_UCB}\n"
		fi
		
	done
	TEMPJPSCMD=`$JPSCMDFILE`
	echo $TEMPJPSCMD | sed -f "../resources/util/common/bin/rmdata.sed"

	TEMPSCMD=`$PSCMD | grep java | grep -v grep |grep -v awk | awk '{print "Process# ", NR, " : ", $0,"\n"} END {if (NR == 0) print ("java process not running")}'`
	echo $TEMPSCMD | sed -f "../resources/util/common/bin/rmdata.sed"

	TEMPSCMD=`$PSCMD_UCB | grep java | grep -v grep |grep -v awk | awk '{print "Process# ", NR, " : ", $0,"\n"} END {if (NR == 0) print ("java process not running")}'`
	
	echo $TEMPSCMD | sed -f "../resources/util/common/bin/rmdata.sed"
	
	$ECHO "[END ORACLE PROCESS INFO]"
}

################################################################################
#
# print out a confirmation after the search and handle debug and error messages
#

printResults() {
	

	# append Unix command errors to the end of the search result file only if debug option is turned on
	if [ "$DEBUG" = "true" ]
	then
		$ECHO "processing.file.debug.data=$LMS_DEBUG_FILE"		
		$ECHO "processing.file.error.data=cat $UNIXCMDERR" 2>/dev/null		
	fi
	
	$ECHO "\nThe Oracle LMS Collection tool has finished.\n"		

		
}


################################################################################
#
# mask sensitive data out of the search results
#

maskResults() {
	PREV_DIR=`pwd`
	#sleep 3 secs for tar to finish before moving on.
	sleep 3
	#mv tar file to temp dir
	mkdir $LMSCT_TMP/masking 
	cp $LMS_TAR_FILE $LMSCT_TMP/masking/.
	# untar file
	# gnu tar supports the -C option so use pax for other *NIXs
	if [ "$OS_NAME" = "Linux" ] ; then
		tar xf $LMSCT_TMP/masking/LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar -C  $LMSCT_TMP/masking/
	else
		cd $LMSCT_TMP/masking/
		pax -r -s ',^/,$LMSCT_TMP/masking/,' -f LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar
		cd $PREV_DIR
	fi
	
	#delete file
	rm $LMSCT_TMP/masking/LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar
	#mask data in temp dir
	perl ./maskdata.pl $LMSCT_TMP/masking/ $MASK_DATA
	if [ ${?} -ne 0 ] ; then
		echo_log "LMSCT: LMS-00021: ERROR: Perl error while masking data occured.  Please see documentation for troubleshooting instructions." $LMSCT_ERRORS
	else
		LMS_TAR_FILE=${OUTPUT_DIR}/LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}-masked.tar	 
		#tar up masked files
		tar cf $LMS_TAR_FILE $LMSCT_TMP/masking/ 2>>$UNIXCMDERR
		$ECHO "\nMasking data completed."
	fi
	#rm tempdir
	rm -rf $LMSCT_TMP/masking/
	
}


################################################################################
#
#*********************************** MAIN **************************************
#
################################################################################

umask 077
setAlias
# command line defaults
SCRIPT_OPTIONS=
SEARCH_DIR="/"
PRODLIST=
REMOTE_DB="NO"
# don't search NFS unless user tells us to 
SEARCH_NFS="false"

# Setup Outputdir to include hostname.pid name in order to be able to have parallel runs.
OS_NAME=`uname -s`
MACHINE_NAME=`uname -n`
LMSCT_PID=${$}

# set tmp directory defaults and files we will use in the script
TMPDIR=/tmp
LMSCT_TMP=${TMPDIR}/lmsct_tmp_${MACHINE_NAME}_${LMSCT_PID}

LMSCT_DEBUG=$LMSCT_TMP/debug

# get directory of LMSCT
CURRENT_DIR=`pwd`
cd `dirname $0` > /dev/null
LMSCT_HOME=`pwd -P`
cd $CURRENT_DIR > /dev/null

OUTPUT_DIR=$LMSCT_HOME/output

FOLLOW="-follow"
LOG_FILE_FLAG="false"
DEBUG="false"
PATH="$PATH:."
export PATH
RANCPUQ="false"
REMOTEINFO=
RUNREMOTE_FILE=
MASKDATA=""
OKTORUNRMDATA="false"
COLLECT_LMS_DEBUG="true"

# set up $ECHO
ECHO="echo_print"

# set up $ECHO for debug
ECHO_DEBUG="echo_debug"

PRODUCTSRUN=""

# check user input
#Replace em_dash if found
ALLARGS=`echo "${@}" | sed -e 's/\xE2\x80\x94/-/g'`
checkSyntax $ALLARGS


chmod o+x $LMSCT_TMP
LMSCT_COLLECTED=$LMSCT_TMP/logs/LMSCT_collected.log
LMSCT_WARNINGS=$LMSCT_TMP/logs/LMSCT_warnings.log
LMSCT_ERRORS=$LMSCT_TMP/logs/LMSCT_errors.log
UNIXCMDERR=$LMSCT_TMP/logs/unixcmderrs.log
touch $UNIXCMDERR


if [ ! -d "$LMSCT_TMP/logs" ] ; then
	mkdir -p $LMSCT_TMP/logs
fi

if [ ! -d "${OUTPUT_DIR}" ] ; then
	mkdir -p "${OUTPUT_DIR}" 
fi	

if [ ! -d "${LMSCT_DEBUG}" ] ; then
	mkdir -p "${LMSCT_DEBUG}"
fi	

if [ ! -d "$LMSCT_TMP/FMW" ] ; then
	mkdir -p $LMSCT_TMP/FMW
fi

if [ "$DEBUG" = "true" ] ; then
	debugWarning
fi

#checkCredtials
if [ "$RUNREMOTE_FILE" != "true" ] ; then 
	credentialValidation
	checkNFS
fi


if [ "$LICAGREE" = "" ] ; then
	# print License Agreement message
	beginMsg 
fi


# Get the products we need to look for
$ECHO "\nRetrieving Oracle Product list...."

if [ "$RUNREMOTE_FILE" != "true" ] ; then
	getProducts
fi 

	
export PRODUCTSRUN
export OUTPUT_DIR
export LICAGREE
export REMOTE_PROD_OPTS
export MASK_DATA
export REMOTE_DB
export LMSCT_HOME
export LMSCT_TMP

# Check for remote execution 
if [ ! -z "$REMOTEINFO" ] ; then
	if [ ! -x ../resources/util/common/bin/recog.sh ] ; then
	
		chmod +x ../resources/util/common/bin/recog.sh
		$ECHO "\nchmod +x on ../resources/util/common/bin/recog.sh script\n"
		if [ ! -x ../resources/util/common/bin/recog.sh ]; then
			echo_log "LMSCT: LMS-00020: ERROR:  The script, ../resources/util/common/bin/recog.sh, is not executable, and the current user is unable to change permissions.\nPlease change persmisions on ../resources/util/common/bin/recog.sh to be executable and re-run the script.\n" $LMSCT_ERRORS
			FLDNUM=`expr ${FLDNUM} + 1`
			continue
		fi
		export REMOTEINFO
		../resources/util/common/bin/recog.sh $SCRIPT_OPTIONS
	else
		export REMOTEINFO
		../resources/util/common/bin/recog.sh $SCRIPT_OPTIONS
	fi
	
		# delete the tmp files
	rm -rf $LMSCT_TMP 1> /dev/null 2>&1

	
else
	# set current system info
	setOSSystemInfo

	RUNNING_STATUS=
	if [ "$OS_NAME" = "Linux" ] ; then
		RUNNING_STATUS=`ps -o stat= -p $$`
	else
		RUNNING_STATUS=`ps -o s= -p $$`
	fi
		
	
	# parse and set search files and process list
	$ECHO "\nSetting up lists for LMS Collection Tool...."
	parseProductFiles
	
	# Run CPUQ before machine info section
	case $RUNLIST in
	   *"cpuq_main"*)
			doRunCmd "$RUNCPUQ"
			RANCPUQ="true";;
	esac

	#export Variables needed by helper scripts
	export OUTPUT_DIR
	export PRODLIST
	export ALLPRODLIST
	export PRODUCTLIST
	export SCRIPT_OPTIONS
	export LICAGREE
	

	# Generate a machine summary file 
	printMachineInfo > $LMS_MACHINFO_FILE 2>>$UNIXCMDERR
	
	
	# check env, java processes, and any beahomeslist found for the default Oracle directories
	# instead of the whole file system
	case $ALLPRODLIST in
		*WLS* )
			getDefaultOracleEnv
			;;
	esac

	# set search option
	setSearchOptions

	# search start time
	setTime
	SEARCH_START=$NOW

	# find all the files on the target system; skip search if CPUQonly or no search files
	if [ "${ALLSEARCHFILES}" != "" ] ; then
		$ECHO "\nRunning file search ..."
		doSearch
	fi

	# search finish time
	setTime
	SEARCH_FINISH=$NOW
	if [ "${ALLSEARCHFILES}" != "" ] ; then
		echo_log "\nLMSCT file search started at $SEARCH_START and finished at $SEARCH_FINISH." $LMS_ACTIONS_RESULTS_FILE		
	fi
	
	
	# Run the specified Commands or scripts
	doRunCmd "$RUNLIST"

	# print search information
	$ECHO "[BEGIN SEARCH INFO]" >> $LMS_MACHINFO_FILE
	$ECHO "Search start=$SEARCH_START" >> $LMS_MACHINFO_FILE
	$ECHO "Search command=$SEARCH_COMMAND" >> $LMS_MACHINFO_FILE
	$ECHO "Search finish=$SEARCH_FINISH" >> $LMS_MACHINFO_FILE
	$ECHO "Search nfs=$SEARCH_NFS" >> $LMS_MACHINFO_FILE
	$ECHO "[END SEARCH INFO]" >> $LMS_MACHINFO_FILE

	if [ -f $LMS_FILES ] ; then
	# obtain unique file list from above search
		$ECHO "\nSorting found file list...."
		fileSort

		# Clean up the file list get rid of non LMS/Oracle config.xml and registry.xml
		$ECHO "\nPreparing Oracle files in file list for collection...."
		fileGetLMSFiles	
	fi
	
	# Name the output file according to which product scripts ran
	LMS_TAR_FILE="${OUTPUT_DIR}/LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar"
	export LMS_TAR_FILE

	# package results for post-processing
	if [ -f $LMS_SORTED_FILES ] ; then

		$ECHO "\nStarting copy of files to the collection archive...."
		fileAction &
		spinner
	fi

	# print output to file
	printResults  >> $LMS_RESULTS_FILE 2>> $UNIXCMDERR

	# Add the compare_result info file to the tar file
	if [ -f compare_result.txt ] ; then
		cp compare_result.txt $LMSCT_TMP/logs/.
	fi

	TARTIMESTAMP=`date '+%Y%m%d_%H%M%S'`
	# check if file exists, if so move older one.
	if [ -f $LMS_TAR_FILE ] ; then
		mv $LMS_TAR_FILE $LMS_TAR_FILE.$TARTIMESTAMP
	fi	

	# bundle the files
	if [ -f $LMS_TAR_FILE_LIST -o -f $LMS_RMDATA_FILE_LIST ] ; then
		bundleResults
	fi
	
		# delete the tmp files
	if [ "$DEBUG" != "true" ] ; then
		rm -rf $LMS_FILES $LMS_SORTED_FILES $LMS_DEBUG_FILE  $LMS_TAR_FILE_LIST 1> /dev/null 2>&1
	fi
	
	# Run rmdata after copying files to secure location
	case $RUNLIST in
	   *"rmdata"*)
			OKTORUNRMDATA="true"
			doRunCmd "$RUNRMDATA"
			;;
	esac
	
	#Check for successful domain gathering
	case $ALLPRODLIST in
		*WLS* )
			for FMW_DOMAINS in `grep "Tar up .*domains.*config.xml.*" $LMS_ACTIONS_RESULTS_FILE | awk '{print $3}' | sed 's/config.*//'`
			do
				echo_log "LMSCT: LMS-00200: COLLECTED: FMW configuration files for $FMW_DOMAINS" $LMSCT_COLLECTED
			done
			;;
	esac
	
	
	for logFiles in $LMSCT_TMP/logs/*_collected.log
	do
		echo "## LMSCT ## Collected" > $LMSCT_TMP/logs/results_summary.log
		if [ -s $logFiles ] ; then
			cat $logFiles >> $LMSCT_TMP/logs/results_summary.log 2>>$UNIXCMDERR
			echo >> $LMSCT_TMP/logs/results_summary.log
		fi
	done

	for logFiles in $LMSCT_TMP/logs/*_warnings.log
	do
		echo "## LMSCT ## Warnings" >> $LMSCT_TMP/logs/results_summary.log
		if [ -s $logFiles ] ; then
			cat $logFiles >> $LMSCT_TMP/logs/results_summary.log 2>>$UNIXCMDERR
			echo >> $LMSCT_TMP/logs/results_summary.log
		fi
	done
	
	for logFiles in $LMSCT_TMP/logs/*_errors.log
	do
		echo "## LMSCT ## Errors" >> $LMSCT_TMP/logs/results_summary.log
		if [ -s $logFiles ] ; then
			cat $logFiles >> $LMSCT_TMP/logs/results_summary.log 2>>$UNIXCMDERR
			echo >> $LMSCT_TMP/logs/results_summary.log
		fi
	done	

	
	#move debug/non neccessary log files to LMSCT_DEBUG
	LMS_ACTIONS_RESULTS_FILE=$LMSCT_DEBUG/LMSCollection-Actions-${MACHINE_NAME}.txt	
	UNIXCMDERR=$LMSCT_DEBUG/unixcmderrs.log

	COPYDBLOGSONLY="true"
	case $ALLPRODLIST in
		*WLS* )
			COPYDBLOGSONLY="false"
			;;
		*OAS* )
			COPYDBLOGSONLY="false"
			;;
		*Tuxedo* )
			COPYDBLOGSONLY="false"
			;;
		*OBI* )
			COPYDBLOGSONLY="false"
			;;
		* )
			;;			
	esac
	
	for DEBUG_FILENAMES in $LMSCT_TMP/logs/*.*
	do

		if [ "$COPYDBLOGSONLY" = "false" ] ; then
			case "$DEBUG_FILENAMES" in 
				*${MACHINE_NAME}-info.txt )
					## don't mv
					;;
				*LMSlogfiles.txt )
					## don't mv
					;;
				*LMSCollection-${MACHINE_NAME}.txt )
					## don't mv
					;;
				*db_list.csv )
					## don't mv
					;;
				*)
					mv "$DEBUG_FILENAMES" "$LMSCT_DEBUG"/.
					;;
			esac
		else 
			case "$DEBUG_FILENAMES" in 
				*db_list.csv )
					## don't mv
					;;
				*)
					mv "$DEBUG_FILENAMES" "$LMSCT_DEBUG"/.
					;;
			esac
		fi
	
	done
	
	LMSCT_COLLECTED=$LMSCT_DEBUG/LMSCT_collected.log
	LMSCT_WARNINGS=$LMSCT_DEBUG/LMSCT_warnings.log
	LMSCT_ERRORS=$LMSCT_DEBUG/LMSCT_errors.log
	UNIXCMDERR=$LMSCT_DEBUG/unixcmderrs.log
	
	if [ "$PRODLIST" = " LMSCPU" ] ; then
		rm -rf $LMSCT_TMP/logs
	fi
	
	TARTIMESTAMP=`date '+%Y%m%d_%H%M%S'`

	LMS_DEBUG_TAR_FILE="${OUTPUT_DIR}/debug_LMSCollection-${MACHINE_NAME}${PRODUCTSRUN}.tar"
	# Add everything to tar file
	bundleLMSOutput	
	$ECHO "\nFinished copying of files to the collection archive."


	# mask data if required.
	if [ "$MASK_DATA" = "all" -o "$MASK_DATA" = "IP" -o "$MASK_DATA" = "ip" -o "$MASK_DATA" = "user" ] ; then
        maskResults
	fi

	
	# check if compressed archive file exists, if so move older one.
	if [ -f $LMS_TAR_FILE.bz2 ] ; then
		mv $LMS_TAR_FILE.bz2 $LMS_TAR_FILE.bz2.$TARTIMESTAMP
	fi
	if [ -f $LMS_TAR_FILE.Z ] ; then
		mv $LMS_TAR_FILE.Z $LMS_TAR_FILE.Z.$TARTIMESTAMP
	fi
	
	LMSRECOG="false"
	case `pwd` in 
		*LMSrecog*)
			LMSRECOG="true"
		;;
	esac
	
	COMPRESSED_NAME=
	# Compress the Results file
	bzip2 $LMS_TAR_FILE 2>>$UNIXCMDERR
	if [ ${?} -ne 0 ] ; then
		compress $LMS_TAR_FILE 2>>$UNIXCMDERR
		if [ ${?} -ne 0 ] ; then
			echo_log "\nCould not compress Results File ${LMS_TAR_FILE}." $LMS_ACTIONS_RESULTS_FILE
			COMPRESSED_NAME=${LMS_TAR_FILE}		
		else
			rm $LMS_TAR_FILE
			echo_log "\nSuccessfully compressed the results file ${LMS_TAR_FILE}." $LMS_ACTIONS_RESULTS_FILE
			COMPRESSED_NAME=${LMS_TAR_FILE}.Z	
		fi
	else
		echo_log "\nSuccessfully compressed the results file ${LMS_TAR_FILE}." $LMS_ACTIONS_RESULTS_FILE
		COMPRESSED_NAME=${LMS_TAR_FILE}.bz2
	fi
	
	clear 2>>$UNIXCMDERR
	
	if [ "$LMSRECOG" = "false" ] ; then
		echo_log "\nCollection process is completed, please forward ${COMPRESSED_NAME} to your LMS Contact." $LMS_ACTIONS_RESULTS_FILE
	fi
	
		
	if [ -f "compare_result.txt" ]
	then
		rm compare_result.txt
	fi

	ECHO_HEADER="true"
	echo
	for logFiles in $LMSCT_DEBUG/*_collected.log
	do
		if [ -s $logFiles ] ; then
			if [ "$ECHO_HEADER" = "true" ] ; then
				echo "## LMSCT ## Collected"
				ECHO_HEADER="false"
			fi
			cat $logFiles
		fi
	done
	ECHO_HEADER="true"
	echo
	for logFiles in $LMSCT_DEBUG/*_warnings.log
	do
		if [ -s $logFiles ] ; then
			if [ "$ECHO_HEADER" = "true" ] ; then
				echo "## LMSCT ## Warnings"
				ECHO_HEADER="false"
			fi		
			
			cat $logFiles 
		fi	
	done
	ECHO_HEADER="true"
	echo
	for logFiles in $LMSCT_DEBUG/*_errors.log
	do
		if [ -s $logFiles ] ; then
			if [ "$ECHO_HEADER" = "true" ] ; then
				echo "## LMSCT ## Errors"
				ECHO_HEADER="false"
			fi		
			
			cat $logFiles
		fi
	done
	
	# delete the tmp files
	rm -rf $LMSCT_TMP 1> /dev/null 2>&1
fi

exit 0

