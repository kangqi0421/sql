--
-- FRA settings
--

set numwidth 20
set lin 250

col name for a15
col ASM_total_GB for 9999
col FRA_limit_GB for 9999
col ASM_Free_GB for 9999
col "REDO_MAX/FRA size [%]" for 999

show parameter db_recovery_file_dest

/*
SELECT name fra_dg, round(total_mb/1024) total_GB,
       round(USABLE_FILE_MB/1024) Usable_Free_File_GB
   FROM v$asm_diskgroup
  WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_recovery_file_dest');
*/

WITH ARCHREDO AS (
SELECT TRUNC (AVG (mb)/1024) as redo_avg, TRUNC (MAX (mb)/1024) redo_max
  FROM (  SELECT TRUNC (COMPLETION_TIME),
                 SUM (blocks * block_size) / 1048576 AS mb
            FROM gv$archived_log
          where first_time > SYSDATE - interval '14' DAY
        GROUP BY TRUNC (COMPLETION_TIME))
)
SELECT
    a.name,
    round(total_mb/1024) ASM_total_GB,
    round(total_mb*0.98/1024) ASM_2pct_GB,
    ROUND(space_limit/power(1024,3)) FRA_limit_GB,
    round(USABLE_FILE_MB/1024) ASM_Free_GB,
    --ROUND(space_used       /power(1024,3)) FRA_used,
    --ROUND(SPACE_RECLAIMABLE/power(1024,3)) FRA_reclaim,
    archredo.redo_avg "redo avg 14 days",
    archredo.redo_max "redo max 14 days",
    ROUND(archredo.redo_max/ROUND(space_limit/power(1024,3))*100) "REDO_MAX/FRA size [%]"
  FROM V$RECOVERY_FILE_DEST r
      INNER JOIN v$asm_diskgroup a ON ltrim(r.name,'+') = a.name,
      archredo
;

prompt V$RECOVERY_AREA_USAGE
prompt
SELECT * FROM V$RECOVERY_AREA_USAGE
  WHERE NUMBER_OF_FILES > 0;

prompt
prompt poslední archivní redo ve FRA - ve dnech
-- aktuální sysdate - maximum redo first time, co je ve FRA
select round(sysdate - max(first_time), 1) "max days FRA"
  from v$archived_log where deleted = 'YES';

--// jak daleko do shistorie muzi jit pøi flashbacku --//
-- prompt oldest flashback time
-- select (sysdate - oldest_flashback_time)*24*60 "min" from v$flashback_database_log;

--// nejstarsi flashback log //--
-- prompt nejstarsi flashback log
-- select min(first_time), (sysdate-min(first_time))*24*60 from v$flashback_database_logfile;

--// ONLINE redo  //--
prompt online redo size
prompt
select THREAD#, bytes/1048576 redo_size_mb, count(*)
 from v$log
 group by THREAD#, bytes/1048576
ORDER by  THREAD#;

prompt optimal_logfile_size z FAST_START_MTTR_TARGET
-- optimal_logfile_size
-- pokud je nastaven FAST_START_MTTR_TARGET
-- the value for optimal_logfile_size is expressed in megabytes and it changes frequently, based on the DML load on your database
select inst_id, optimal_logfile_size, TARGET_MTTR, ESTIMATED_MTTR from gv$instance_recovery;

prompt Redo switching - Histogram - last interval '14' DAY
prompt idealne kolem 20-ti minut
column  minutes  format a12
SELECT (
    CASE WHEN bucket = 1 THEN '<= ' || TO_CHAR(bucket* 5)
         WHEN (bucket >1 AND bucket < 9) THEN TO_CHAR(bucket * 5 - 4) || ' TO ' || TO_CHAR(bucket * 5)
         WHEN bucket > 8 THEN '>= ' || TO_CHAR(bucket * 5 - 4) END)
       "MINUTES",
    switches "LOG_SWITCHES" FROM (
      SELECT bucket , COUNT(b.bucket) SWITCHES
        FROM (
          SELECT WIDTH_BUCKET(ROUND((b.first_time - a.first_time) * 1440), 0, 40, 8) bucket
            FROM v$archived_log a,
                 v$archived_log b
          WHERE (a.sequence# + 1) = b.sequence#
            AND a.dest_id = b.dest_id
            AND a.thread# = b.thread#
            AND a.first_time > SYSDATE - interval '14' DAY
            AND a.dest_id = (
              SELECT MIN(dest_id) FROM gv$archive_dest WHERE target = 'PRIMARY' AND destination IS NOT NULL)) b
    GROUP BY bucket ORDER BY bucket)
;