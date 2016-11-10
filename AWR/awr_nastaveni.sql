--// snapshot interval, retention interval //--
select
      DBID,
      extract( day from snap_interval) *24*60+extract( hour from snap_interval) *60+extract( minute from snap_interval ) "Snapshot Interval [min]",
	  extract( day from retention ) "Retention [days]",
      extract( day from retention) *24*60+extract( hour from retention) *60+extract( minute from retention ) "Retention [mins]"
from dba_hist_wr_control
 where dbid in (select dbid from v$database);

select snap_interval, retention from dba_hist_wr_control;

-- ZMENY v AWR ---
-- snapshot po 30-ti min
exec  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( interval => 30);
-- snapshot po hodinì, default
exec  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( interval => 60);

-- retention 14 dni (20160 minut)
exec  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>20160);
-- retention 31 dni (44640 minut)
exec  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>44640);

-- AWR collections trace
alter session set "_swrf_test_action" = 28;
alter session set "_swrf_test_action" = 10;
-- off
alter session set "_swrf_test_action" = 29;
alter session set "_swrf_test_action" = 11;

and check MMON trace


-- SYSAUX occupants
@?/rdbms/admin/awrinfo.sql

SELECT
  OCCUPANT_NAME,
  SCHEMA_NAME,
  ROUND(SPACE_USAGE_KBYTES/1024) "MB"
FROM
  V$SYSAUX_OCCUPANTS
ORDER BY
  space_usage_kbytes DESC
FETCH FIRST 2 ROWS ONLY
;

-- SM/AWR
-- baselines, které lze pripadne odstranit
select BASELINE_ID,START_SNAP_ID,END_SNAP_ID from SYS.WRM$_BASELINE;

-- min/max
select min(snap_id), max(snap_id) from dba_hist_snapshot;

-- SM/OPTSTAT
-- Purging statistics from the SYSAUX tablespace
http://jhdba.wordpress.com/2009/05/19/purging-statistics-from-the-sysaux-tablespace/

-- retention stats history
select cast(dbms_stats.get_stats_history_availability as date) from dual;

-- zmìna na 10 dní
exec dbms_stats.alter_stats_history_retention(10);
exec DBMS_STATS.PURGE_STATS(SYSDATE-10);

-- table segments stats
select round(sum(bytes/1024/1024)) MB, segment_name,segment_type from dba_segments
where  tablespace_name = 'SYSAUX'
and segment_name like 'WRI$_OPTSTAT%'
and segment_type='TABLE'
group by segment_name,segment_type order by 1 desc;

-- index segments stats
select round(sum(bytes/1024/1024)) MB, segment_name,segment_type from dba_segments
where  tablespace_name = 'SYSAUX'
and segment_name like '%OPT%'
and segment_type='INDEX'
group by segment_name,segment_type order by 1 desc;

-- rebuild online parallel indexes - pokud
select 'alter index '||segment_name||'  rebuild online parallel;'
  from dba_segments where tablespace_name = 'SYSAUX'
 and segment_name like '%OPT%' and segment_type='INDEX';

alter index I_WRI$_OPTSTAT_HH_OBJ_ICOL_ST  rebuild online parallel;
alter index I_WRI$_OPTSTAT_H_ST  rebuild online parallel;
alter index I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST  rebuild online parallel;


