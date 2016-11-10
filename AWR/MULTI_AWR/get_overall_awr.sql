-- spool 1 AWR report for query 
-- +-1 snapshot pred a po EOD

define fn_name='text'

SET heading off verify off feed off trim on lin 32767

spool gen_awr.sql
-- HTML
--SELECT 'set veri off feedback off linesize 1500 termout on pagesize 0;'||CHR(10) FROM dual;
-- TEXT
SELECT 'set veri off feedback off linesize 80 termout on pagesize 0;'||CHR(10) FROM dual;

SELECT  'spool awrrpt_'||SYS_CONTEXT ('USERENV', 'DB_NAME')||'_'||TO_CHAR(inst_id)||
        '_'||to_char(begin_time,'YYMMDD_HH24MI')||'.&fn_name'||CHR(10)|| 
   'SELECT * FROM TABLE(dbms_workload_repository.awr_report_&fn_name('||TO_CHAR(dbid)||','||TO_CHAR(inst_id)||','||TO_CHAR(min_snap_id)||','||TO_CHAR(max_snap_id)||',8));'||
        CHR(10)||'spool off' 
FROM (
WITH
  -- definice rozsahu AWR id
  range AS
  (
  --
    SELECT   start_time start_time, nvl(end_time, sysdate) end_time
       FROM dba_workload_replays
       WHERE start_time =
    (
      SELECT   MAX(start_time)
        FROM dba_workload_replays
--        WHERE status = 'COMPLETED'
    )
  --
  )
SELECT
  min(instance_number) inst_id,max(dbid) dbid,
  min(begin_interval_time) begin_time, max(end_interval_time) end_time,
  min(snap_id)-1 min_snap_id, max(snap_id)+1 max_snap_id
FROM
  dba_hist_snapshot sn,
  range e
WHERE
  sn.end_interval_time      >= e.start_time
  and sn.end_interval_time  <  e.end_time
  AND instance_number = sys_context('USERENV', 'INSTANCE')
  AND dbid=(select dbid from v$database where name=SYS_CONTEXT ('USERENV', 'DB_NAME'))
  )
  ;
  
--SELECT 'exit'||CHR(10) FROM dual;

spool off;  
