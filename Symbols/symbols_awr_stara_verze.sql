-- spool 1 AWR report for EOD/EOM Symbols
-- +-15 minut snapshot period

define fn_name='text'
SET heading off verify off feed off trim on

spool gen_awr.sql
-- HTML
-- SELECT 'set veri off feedback off linesize 8000 termout on pagesize 0;'||CHR(10) FROM dual;
-- TEXT
SELECT 'set veri off feedback off linesize 80 termout on pagesize 0;'||CHR(10) FROM dual;

SELECT  'spool awrrpt_'||SYS_CONTEXT ('USERENV', 'DB_NAME')||'_'||TO_CHAR(inst_id)||
        '_'||to_char(begin_time,'YYMMDD_HH24MI')||
        '_'||to_char(end_time,'YYMMDD_HH24MI')||'.&fn_name'||CHR(10)|| 
   'SELECT * FROM TABLE(dbms_workload_repository.awr_report_&fn_name('||TO_CHAR(dbid)||','||TO_CHAR(inst_id)||','||
        TO_CHAR(min_snap_id)||','||TO_CHAR(max_snap_id)||',8));'||
        CHR(10)||'spool off' 
FROM (
WITH
  eod AS
  (
    SELECT  MIN(start_time) eod_start,  MAX(end_time)   eod_end
      FROM symbols.fm_process  WHERE process_seq_no > 0
  )
SELECT
  min(instance_number) inst_id,max(dbid) dbid,
  min(begin_interval_time) begin_time, max(end_interval_time) end_time,
  min(snap_id) min_snap_id, max(snap_id) max_snap_id
FROM
  dba_hist_snapshot sn,
  eod e
WHERE
  sn.end_interval_time      >= e.eod_start-15/(24*60)
  and sn.end_interval_time  <=  e.eod_end  +15/(24*60)
  AND instance_number = sys_context('USERENV', 'INSTANCE')
  AND dbid=(select dbid from v$database where name=SYS_CONTEXT ('USERENV', 'DB_NAME'))
  )
  ;
  
spool off;  