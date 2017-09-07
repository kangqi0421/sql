--
-- redo switching
--
--

prompt pocet redologu - z alert.logu dle hlasky checkpoint has not completed
prompt velikost redologu - redolog switch should be each 20 min.
prompt  Use redo log size >= peak redo rate x 20 minutes


prompt online redo size
prompt
select THREAD#, bytes/1048576 redo_size_mb, count(*)
 from v$log
 group by THREAD#, bytes/1048576;

col member for a60
select THREAD#, l.GROUP#, member, bytes/1048576
  from v$log l join v$logfile f on l.group# = f.group#
  order by THREAD#, f.GROUP#;

-- the value for optimal_logfile_size is expressed in megabytes and it changes frequently, based on the DML load on your database
--
prompt optimal_logfile_size z FAST_START_MTTR_TARGET
-- optimal_logfile_size
-- pokud je nastaven FAST_START_MTTR_TARGET
-- the value for optimal_logfile_size is expressed in megabytes and it changes frequently, based on the DML load on your database
select inst_id, optimal_logfile_size, TARGET_MTTR, ESTIMATED_MTTR from gv$instance_recovery;

prompt redo switch over 20 minutes
SELECT fs.log_switches_under_20_mins, ss.log_switches_over_20_mins FROM (SELECT  SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_UNDER_20_MINS"  FROM v$archived_log a, v$archived_log b WHERE a.sequence# + 1 = b.sequence# AND a.dest_id = 1 AND a.thread# = b.thread#  AND a.dest_id = b.dest_id AND a.dest_id = (SELECT MIN(dest_id) FROM gv$archive_dest WHERE target='PRIMARY' AND destination IS NOT NULL) AND ROUND((b.first_time - a.first_time) * 1440)  < 20 GROUP BY ROUND((b.first_time - a.first_time) * 1440))  fs, (SELECT  SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_OVER_20_MINS"  FROM v$archived_log a, v$archived_log b WHERE a.sequence# + 1 = b.sequence# AND a.dest_id = 1 AND a.thread# = b.thread#  AND a.dest_id = b.dest_id AND a.dest_id = (SELECT MIN(dest_id) FROM gv$archive_dest WHERE target='PRIMARY' AND destination IS NOT NULL) AND ROUND((b.first_time - a.first_time) * 1440)  > 19 GROUP BY ROUND((b.first_time - a.first_time) * 1440)) ss;

prompt Redo switching - Histogram
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
            AND a.first_time > SYSDATE - interval '7' DAY
            AND a.dest_id = (
              SELECT MIN(dest_id) FROM gv$archive_dest WHERE target = 'PRIMARY' AND destination IS NOT NULL)) b
    GROUP BY bucket ORDER BY bucket)
;


/*
--detecting who’s causing excessive redo generation
@snapper "all,gather=s,sinclude=redo size" 10 1 all

-- LGWR
@snapper "all" 10 1 LGWR

--Guess the object using ‘db block changes’ statistics
gv$segment_statistics


*/