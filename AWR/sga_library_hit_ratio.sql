SELECT se.snap_id, se.snap_time,
       round(ev.hsum / ev.psum, 3), ev.psum, ev.hsum
  FROM (SELECT sn.snap_id, sn.snap_time, sn.dbid, sn.instance_number
          FROM stats$snapshot sn) se,
       (SELECT e.snap_id, e.dbid, e.instance_number,
               CASE
                  WHEN (e.psum - NVL (b.psum, 0)) > = 0
                     THEN e.psum - NVL (b.psum, 0)
                  ELSE e.psum
               END psum,
               e.psum total_psum,
               CASE
                  WHEN (e.hsum - NVL (b.hsum, 0)) >= 0
                     THEN e.hsum - NVL (b.hsum, 0)
                  ELSE e.hsum
               END hsum,
               e.hsum total_hsum
          FROM (SELECT   snap_id, dbid, instance_number, SUM (pins) psum,
                         SUM (pinhits) hsum
                    FROM stats$librarycache
                GROUP BY snap_id, dbid, instance_number) b,
               (SELECT   snap_id, dbid, instance_number, SUM (pins) psum,
                         SUM (pinhits) hsum
                    FROM stats$librarycache
                GROUP BY snap_id, dbid, instance_number) e
         WHERE b.snap_id(+) = e.snap_id - 1 AND b.dbid(+) = e.dbid
               AND b.instance_number(+) = e.instance_number) ev
 WHERE se.snap_time > trunc(sysdate - 14 ) --se.snap_id between 71721 and 71912
   AND ev.dbid(+) = se.dbid
   AND ev.instance_number(+) = se.instance_number
   AND ev.snap_id(+) = se.snap_id
   order by se.snap_id
    
