-- spool 1 AWR report for query 
-- +-1 snapshot pred a po EOD

define fn_name='text'

SET heading off verify off feed off trim on pages 0

spool gen_awr.sql
-- HTML
--SELECT 'set veri off feedback off linesize 1500 termout on pagesize 0;'||CHR(10) FROM dual;
-- TEXT
SELECT 'set veri off feedback off linesize 80 termout on pagesize 0;'||CHR(10) FROM dual;

SELECT  
   'spool awrrpt_'||SYS_CONTEXT ('USERENV', 'DB_NAME')||'_'||TO_CHAR(instance_number)||
        '_'||to_char(end_interval_time,'YYMMDD_HH24MI')||'.&fn_name'||CHR(10)|| 
   'SELECT * FROM TABLE(dbms_workload_repository.awr_report_&fn_name '||CHR(10)||
            '('||TO_CHAR(dbid)||','||TO_CHAR(instance_number)||','||TO_CHAR(snap_id)||','||TO_CHAR(next_snap)||',8)'||CHR(10)||
            ');'||CHR(10)||
    'spool off' 
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
   instance_number,dbid,
   snap_id,
   LAG(snap_id, 1, 0) OVER (PARTITION BY instance_number ORDER BY snap_id DESC NULLS LAST) next_snap,
   end_interval_time
FROM
  dba_hist_snapshot sn,
  range e
WHERE
  -- korekce snap_id na +-1 hodina kolem zadaneho rozsahu
      sn.end_interval_time  >= e.start_time - 1/24
  and sn.end_interval_time  <  e.end_time + 1/24
--  AND instance_number = sys_context('USERENV', 'INSTANCE')
  AND dbid=(select dbid from v$database where name=SYS_CONTEXT ('USERENV', 'DB_NAME'))
ORDER BY snap_id
  )
  WHERE next_snap > 0  
  ;
  
SELECT 'exit'||CHR(10) FROM dual;

spool off;  
