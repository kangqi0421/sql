define _interval=1   --1 interval between snap and next snap  2 snap and second next snap
define _database_name='KMP0'
define _begin_interval_date='281211 10:00:00' -- DDMMYY HH24:MI:SS
define _end_interval_date='281211 14:00:00'
define _folder='D:\scratch'

SET heading off verify off feed off trim on

spool gen_awr.sql
SELECT 'set veri off feedback off linesize 1500 termout on pagesize 0;'||CHR(10) FROM dual;
SELECT  'spool &_folder\awrrpt_&_database_name'||'_'||TO_CHAR(instance_number)||'_'||to_char(begin_interval_time,'YYMMDD_HH24MI')||'_'||to_char(end_interval_time,'YYMMDD_HH24MI')||'.html'||CHR(10)|| 
'SELECT * FROM TABLE(dbms_workload_repository.awr_report_html('||TO_CHAR(dbid)||','||TO_CHAR(instance_number)||','||TO_CHAR(previous_snap_id)||','||TO_CHAR(snap_id)||',8));'||CHR(10)||'spool off' 
FROM (
select instance_number,dbid,snap_id,
LEAD(snap_id, &_interval, 0) OVER (PARTITION BY instance_number ORDER BY snap_id DESC NULLS LAST) previous_snap_id,
LAG(snap_id, &_interval, 0) OVER (PARTITION BY instance_number ORDER BY snap_id DESC NULLS LAST) next_snap_id,
begin_interval_time ,end_interval_time
from dba_hist_snapshot 
where dbid=(select dbid from v$database where name='&_database_name')
AND instance_number in (select DISTINCT inst_id from gv$database  )
AND begin_interval_time>=TO_DATE('&_begin_interval_date','DDMMYY HH24:MI:SS')-1/24
AND begin_interval_time<TO_DATE('&_end_interval_date','DDMMYY HH24:MI:SS')+1/24
) WHERE next_snap_id<>0 AND previous_snap_id<>0
order by instance_number,begin_interval_time asc;

spool off;