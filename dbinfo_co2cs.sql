select (select HOST_NAME||':'||INSTANCE_NAME||':' from v$instance)||( select BANNER from v$version where rownum=1 )||':'||
( select trunc(sum(bytes)/1048576) as MB from v$datafile )||':'||
( select trunc(sum(value)/1048576) from v$sga )||':'||
( select MAX_UTILIZATION||':'||ltrim(LIMIT_VALUE) from v$resource_limit where RESOURCE_NAME='sessions' )||':'||
(
select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
( select value from v$parameter where name='pga_aggregate_target' )
  ELSE 'N/A' END from dual
)||':'||
( select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 8  THEN
  ( select min(PGA_TARGET_FACTOR) from  V$PGA_TARGET_ADVICE where PGA_TARGET_FACTOR<=1 and ESTD_PGA_CACHE_HIT_PERCENTAGE>95 )
    ELSE -99 END from dual
)||':'||
( select case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
  ( select min(SGA_SIZE_FACTOR) from  V$SGA_TARGET_ADVICE where SGA_SIZE_FACTOR<=1 and ESTD_DB_TIME_FACTOR>0.95 )
    ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh$_stat_name
WHERE stat_name = 'physical read total bytes')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh$_stat_name
WHERE stat_name = 'physical write total bytes')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh$_stat_name
WHERE stat_name = 'bytes received via SQL*Net from client')
)
)
ELSE -99 END from dual
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
(
select max(PR) as "MB/S"
from
(
select
  round((VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/1048576) as PR
FROM SYS.wrh$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id
FROM SYS.wrh$_stat_name
WHERE stat_name = 'bytes sent via SQL*Net to client')
)
)
ELSE -99 END from dual
)||':'||
(
select trunc(avg(mb)) from ( select trunc(COMPLETION_TIME),sum(blocks*block_size)/1048576 as mb from v$archived_log group by trunc(COMPLETION_TIME))
)||':'||
(
select trunc(max(mb)) from ( select trunc(COMPLETION_TIME),sum(blocks*block_size)/1048576 as mb from v$archived_log group by trunc(COMPLETION_TIME))
)||':'||
(
select 
case when (select to_number(substr(VERSION,1,instr(version,'.')-1)) from v$instance) > 9  THEN
(
select round(avg(PR),2)||':'||round(max(PR),2)
from
(
select
  (VALUE - LAG (VALUE, 1) OVER (PARTITION BY e.stat_id,e.instance_number ORDER BY e.snap_id)) / (to_number(extract(second from (s.end_interval_time-s.begin_interval_time)))+ to_number(extract(minute from ((s.end_interval_time-s.begin_interval_time))))*60+to_number(extract(hour from (s.end_interval_time-s.begin_interval_time)))*3600)/100 as PR
FROM SYS.wrh$_sysstat e, dba_hist_snapshot s
WHERE e.snap_id = s.snap_id and e.instance_number=s.instance_number and e.instance_number=1
AND stat_id IN (SELECT stat_id FROM SYS.wrh$_stat_name WHERE stat_name = 'CPU used by this session')
)
)
ELSE '-99:-99' END from dual
)
from dual
/
