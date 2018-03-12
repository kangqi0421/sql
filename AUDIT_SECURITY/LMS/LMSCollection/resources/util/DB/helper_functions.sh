#!/bin/sh
#
#
#  This script defines some helper functions to be used in
#  other scripts so as to not have to define them every time
#  they are used.
#
#

############################################################
#  make echo more portable
#
#
 echo_print() {

  #IFS=" "  command
  eval 'printf "%b\n" "$*"'
}

echo_n_print() 
{
  eval 'printf "%b" "$*"'
}


############################################################
#
# expand debug output
#
 echo_debug() {

   if [ "$DEBUG" = "true" ] ; then
      $ECHO "$*"
      $ECHO "$*" >> $DEBUG_FILE
   fi

 }

############################################################
#
# time stamp
#

setTime() {

  #  set time
  NOW="`date '+%m/%d/%Y %H:%M %Z'`"

}


setAlias() {
unalias -a

cmd_list="printf
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
ls
"

path_list="/bin/
/usr/bin/"


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
   if [ "${alias_not_found}" = "" ]; then
      alias_not_found=$c
   else       
     alias_not_found=${alias_not_found},$c
   fi            
 fi
done

 if [ "${alias_not_found}" != "" ]; then 
   eval 'printf "${alias_not_found} utility(ies) not found. Please contact your LMS representative"'
  exit 600
fi
#alias
}


ECHO="echo_print"
ECHON="echo_n_print"
