#!/bin/sh

current_dir=`pwd`
db_config_file="../resources/products/DB/DB.txt"
source_dir="../resources/util/DB"
output_dir="${LMSCT_TMP}"
log_dir="${LMSCT_TMP}/logs"
working_dir="${LMSCT_TMP}/db_tmp" 

if [ ! -d "$working_dir" ] ; then
	mkdir -p "$working_dir" 
fi

if [ ! -d "$log_dir" ] ; then
	mkdir "$log_dir"
fi

cp -p ../resources/util/DB/* "${working_dir}/."
cd "$working_dir"

chmod +x *.sh

echo $ALLPRODLIST | grep "EBS" > /dev/null
if [ $? = 0 ]; then
	vprodlist="DB~EBS"		
else
	vprodlist="DB"		
fi	

export vprodlist


if [ -f oracle_homes_a.txt ] ; then
	rm -f oracle_homes_*.txt
fi

if [ "$LICAGREE" = "YES" ]; then
	./look_for_running_sids.sh "db_conn_coll_main.sql YES $vprodlist"
else
	./look_for_running_sids.sh "db_conn_coll_main.sql NO $vprodlist"
fi

./db_conn_coll.sh NO db_list.csv
./logcolstat.sh ALL YES

rm -f *_sql_*.log

for log in `ls *.log`
do
if [ ! -s $log ]; then
	rm -f $log
fi
done 

for f in DB DBA_FUS EBS
do
if [ -d "$f" ]; then
	cp -pR "$f" "$output_dir/."
	cp $f*.csv "$output_dir/$f/."
	rm -rf "$f"
	rm -rf $f*.csv
fi	
done

cp *.log "$log_dir/."
cp *.csv "$log_dir/."
cp temp*.sql "$log_dir/."


cd "$current_dir"
rm -rf "$working_dir"
