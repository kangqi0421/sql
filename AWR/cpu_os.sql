/* CPU OS BUSY time */ 

  SELECT b.end_interval_time, a.stat_name, ROUND (a.VALUE / 100)
    FROM SYS.DBA_HIST_OSSTAT a, SYS.DBA_HIST_SNAPSHOT b
   WHERE stat_id = 2 AND a.snap_id = b.snap_id
ORDER BY b.end_interval_time


select stat_id, stat_name from SYS.DBA_HIST_OSSTAT_NAME;