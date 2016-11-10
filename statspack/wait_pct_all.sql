SELECT a.snap_id, TO_CHAR (a.snap_time, 'dd.mm.yyyy hh24:mi') "snap time", 
	   a.wait_time "wait [s]",
	   a.waits "#waits",
           b.all_time "all waits [s]"
  FROM (SELECT snap_id, snap_time, time wait_time, waits
          FROM events
         WHERE event = 'enqueue') a,
       (SELECT   e.snap_id, SUM (e.TIME) all_time
            FROM events e
           WHERE e.event NOT IN (SELECT event
                                   FROM stats$idle_event)
        GROUP BY e.snap_id) b
 WHERE a.snap_id = b.snap_id
	and a.snap_time > to_date('30.10.04', 'dd.mm.yy');	