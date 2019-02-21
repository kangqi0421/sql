#!/bin/sh
# Sber zakladnich informaci o DB Oracle ve tvaru
# ORACLE_SID
# HOSTNAME
# PLATFORMA
# VERZE ORACLE
# VELIKOST DB V MB
# SGA-MB
# MAXPOCETPSESSIONSODRESTARTU
# LIMITSESSION
# Velikost PGA pro 9i a vyse
# PGA TARGET ADVICE pro 9i a vyse
# SGA TARGET ADVICE pro 10g a vyse
# Maximum Physical reads   MB/s pro 10g a vyse
# Maximum Physical writes  MB/s pro 10g a vyse
# Maximum Network IO  rx MB/s pro 10g a vyse
# Maximum Network IO  tx MB/s pro 10g a vyse
# Average Redo/Day v MB
# Maximum Redo/Day v MB

# vystup je na stdout

# verze 1.2 Vit Hlavacek, Oracle

GetDB() {
ps -ef | grep ora_smon | grep -v grep | awk '{print $NF}' | while read SID
do
 echo ${SID#ora_smon_}
done
}

GetUser() {
ps -ef | grep ora_smon_$ORACLE_SID | grep -v grep | awk '{print $1}'
}

GetPlatform() {
 PL=$(uname -s)
 if [[ "$PL" = "HP-UX" ]]
 then
  PS1="$(uname -sr) $(model)"
 else
  PS1="$(uname -srv)"
 fi
 echo "$PS1"
}

RunSQL() {
cat <<EOF
export ORACLE_SID=$ORACLE_SID
export ORACLE_HOME=$ORACLE_HOME
$ORACLE_HOME/bin/sqlplus /nolog <<-SQL
connect / as sysdba
set lines 1000 pages 999 trims on hea off
select 'VHL^'||( select BANNER from v\\\$version where rownum=1 )||':'||
( select trunc(sum(bytes)/1048576) as MB from v\\\$datafile )||':'||
( select trunc(sum(value)/1048576) from v\\\$sga )||':'||
( select MAX_UTILIZATION||':'||ltrim(LIMIT_VALUE) from v\\\$resource_limit where RESOURCE_NAME='sessions' )||':'||
(
select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
( select value from v\\\$parameter where name='pga_aggregate_target' )
  ELSE 'N/A' END from dual
)||':'||
( select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 8  THEN
  ( select min(PGA_TARGET_FACTOR) from  V\\\$PGA_TARGET_ADVICE where PGA_TARGET_FACTOR<=1 and ESTD_PGA_CACHE_HIT_PERCENTAGE>95 )
    ELSE -99 END from dual
)||':'||
( select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
  ( select min(SGA_SIZE_FACTOR) from  V\\\$SGA_TARGET_ADVICE where SGA_SIZE_FACTOR<=1 and ESTD_DB_TIME_FACTOR>0.95 )
    ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh\\\$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh\\\$_stat_name
WHERE stat_name = 'physical read total bytes')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh\\\$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh\\\$_stat_name
WHERE stat_name = 'physical write total bytes')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh\\\$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh\\\$_stat_name
WHERE stat_name = 'bytes received via SQL*Net from client')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v\\\$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh\\\$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh\\\$_stat_name
WHERE stat_name = 'bytes sent via SQL*Net to client')
)
)
ELSE -99 END from dual
)||':'||
(
select trunc(avg(mb)) from ( select trunc(COMPLETION_TIME),sum(blocks*block_size)/1048576 as mb from v\\\$archived_log group by trunc(COMPLETION_TIME))
)||':'||
(
select trunc(max(mb)) from ( select trunc(COMPLETION_TIME),sum(blocks*block_size)/1048576 as mb from v\\\$archived_log group by trunc(COMPLETION_TIME))
)
from dual
/
exit
SQL
EOF
}

GetVS() {
#pro verzi jako root
#su $(GetUser) <<EOF | grep 'VHL^' | awk -F\^ '{print $2}'
#pro verzi jako oracle
sh <<EOF | grep 'VHL^' | awk -F\^ '{print $2}'
$(RunSQL)
EOF
}

GetDB | while read SID
do
 PLATFORM=$(GetPlatform)
 ORACLE_SID=$SID
#ORACLE_HOME=source z env file
 export ORAENV_ASK=NO
 . oraenv $ORACLE_SID >/dev/null 2>&1
 export ORACLE_SID
 export ORACLE_HOME
 DB=$(GetVS)
 echo "$SID;$(hostname);${PLATFORM};${DB}"
done
