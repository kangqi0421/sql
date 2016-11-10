/** 
   instance response time
   cpu to wait ratio
**/
SELECT TO_CHAR (a.snap_time, 'dd.mm.yyyy hh24:mi') "snap time", 
	   a.cpu_time "cpu [s]",
       b.wait_time "wait [s]",
	   a.cpu_time + b.wait_time "response time [s]",
       ROUND (a.cpu_time / (a.cpu_time + b.wait_time) * 100, 1) "cpu [%]",
	   ROUND (b.wait_time / (a.cpu_time + b.wait_time) * 100, 1) "wait [%]"
  FROM (SELECT snap_id, snap_time, VALUE cpu_time
          FROM sysstat_per_sec
         WHERE NAME = 'CPU used by this session') a,
       (SELECT   e.snap_id, SUM (e.TIME) wait_time
            FROM events e
           WHERE e.event NOT IN (SELECT event
                                   FROM stats$idle_event)
        GROUP BY e.snap_id) b
 WHERE a.snap_id = b.snap_id
 AND a.snap_id BETWEEN &snap_start AND &snap_konec
 order by snap_time
 
