/* CPU used / parse time */
SELECT   sn.snap_time, 
		 cpu.VALUE "CPU used", 
		 parse.VALUE "parse time cpu",
         elapsed.VALUE "parse time elapsed"
    FROM (SELECT snap_id, NAME, VALUE
            FROM sysstat_per_sec
           WHERE NAME = 'CPU used by this session') cpu,
         (SELECT snap_id, NAME, VALUE
            FROM sysstat_per_sec
           WHERE NAME = 'parse time cpu') parse,
         (SELECT snap_id, NAME, VALUE
            FROM sysstat_per_sec
           WHERE NAME = 'parse time elapsed') elapsed,
         stats$snapshot sn
   WHERE cpu.snap_id = parse.snap_id
     AND parse.snap_id = elapsed.snap_id
     AND elapsed.snap_id = sn.snap_id
ORDER BY snap_time