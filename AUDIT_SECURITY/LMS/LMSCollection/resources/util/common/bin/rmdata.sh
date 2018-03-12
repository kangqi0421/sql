#!/bin/sh

SCRIPT_VERSION="18.1($LMSCT_BUILD_VERSION)"
SCRIPT_NAME=${0}
##########################################################################################
##   rmdata.sh     v 18.1
##	  - scrub collected data of passwords or encryped information.
##

ECHO_rmdata="echo_rmdata_print"
##############################################################
# make echo more portable
#

echo_rmdata_print() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 

##############################################################
# make echo more portable
#

echo_rmdata_log() {
	$ECHO_rmdata "$1" 
	$ECHO_rmdata "$1" >> $2
} 


$ECHO_rmdata "\nRemoving passwords and ecnrypted information..." 
old_IFS=$IFS      # save the field separator           
 # new field separator, the end of line 
IFS='
'    
if [ -f $LMSCT_TMP/logs/LMSRMDATACopiesfilelist.txt ] ; then
 	for file in `cat $LMSCT_TMP/logs/LMSRMDATACopiesfilelist.txt`
	do
		sed -f $LMSCT_HOME/../resources/util/common/bin/rmdata.sed $file > $file.tmp 
		if [ ${?} -ne 0 ] ; then
			rm $file.tmp 
			rm $file
		else
			mv $file.tmp $file
		fi

	done
fi
IFS=$old_IFS     # restore default field separator 


