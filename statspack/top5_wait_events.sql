SELECT b.snap_id, b.snap_time, a.event, a.c_time_waited "wait time",
       c.total_wait_time "total wait time",
       ROUND ((a.c_time_waited / c.total_wait_time * 100), 2 ) "wait time event [%]"
  FROM top_5_events a,
       stats$snapshot b,
       (SELECT   e.snap_id, SUM (e.TIME) total_wait_time
            FROM events e
           WHERE e.event NOT IN (SELECT event
                                   FROM stats$idle_event)
        GROUP BY e.snap_id) c
 WHERE a.snap_id = b.snap_id AND b.snap_id = c.snap_id
       AND a.snap_id = c.snap_id
 order by 1, 4 desc 	   
	   