/* wait event total waits */
SELECT b.snap_id, b.snap_time, b.event, b.waits "waits#",
	   b.TIME/100 "wait time [s]",
       a.SUM/100 "total wait time [s]", ROUND (b.TIME / a.SUM * 100) "wait time event [%]"
  FROM (SELECT   b.snap_id, SUM (c_time_waited) SUM
            FROM top_5_events a, stats$snapshot b
           WHERE a.snap_id = b.snap_id
        GROUP BY b.snap_id) a,
       (SELECT snap_time, snap_id, a.event, waits, TIME
          FROM events a
         WHERE a.event = 'enqueue') b
 WHERE a.snap_id = b.snap_id
  	   and b.snap_time > TO_DATE ('30.10.04', 'dd.mm.yy')