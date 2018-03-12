#!/bin/sh

current_dir=`pwd`
output_dir="${LMSCT_TMP}/LMSCPU"
log_dir="${LMSCT_TMP}/logs"
source_dir="../resources/util/LMSCPU"

if [ ! -d "$output_dir" ] ; then
	mkdir -p "$output_dir" 
fi

if [ ! -d "$log_dir" ] ; then
	mkdir "$log_dir"
fi

cd $source_dir
chmod +x lms_cpuq.sh
./lms_cpuq.sh "${output_dir}" 

cd $output_dir
grep 'LMSCPU: LMS-[0-9][0-9][0-9][0-9][0-9]: WARNING:' *-lms_cpuq.txt  >$log_dir/LMSCPU_warnings.log
grep 'LMSCPU: LMS-[0-9][0-9][0-9][0-9][0-9]: ERROR:' *-lms_cpuq.txt  >$log_dir/LMSCPU_errors.log
grep 'Machine Name=' *-lms_cpuq.txt | sed 's/Machine Name=/LMSCPU: LMS-01000: COLLECTED: Machine Name: /g' >$log_dir/LMSCPU_collected.log


for log in `ls $log_dir/LMSCPU_*.log`
do
if [ ! -s $log ]; then
	rm -f $log
fi
done 

cd "$current_dir"