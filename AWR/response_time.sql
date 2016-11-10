/* resonse time */
SELECT   a.SID, VALUE "CPU", c_time "Waits", VALUE + c_time "total",
         ROUND (a.VALUE / (a.VALUE + b.c_time) * 100, 1) "cpu [%]",
         ROUND (b.c_time / (a.VALUE + b.c_time) * 100, 1) "wait [%]"
    FROM (SELECT SID, 'CPU' CLASS, VALUE
            FROM v$sesstat st, v$statname sn
           WHERE sn.statistic# = st.statistic#
             AND sn.NAME LIKE 'CPU used by this session') a,
         (SELECT   e.SID, SUM (time_waited) c_time
              FROM v$session_event e
             WHERE e.event NOT IN
                         ('PL/SQL lock timer', 'SQL*Net message from client')
               AND e.time_waited <> 0
          GROUP BY e.SID) b
   WHERE a.SID = b.SID AND a.SID IN (SELECT SID
                                       FROM v$session
                                      WHERE TYPE = 'USER')
ORDER BY 1

/* top ten wait eventu */
SELECT   SID, event, time_waited
    FROM v$session_event
   WHERE time_waited > 0
     AND event NOT IN ('PL/SQL lock timer', 'SQL*Net message from client')
     AND SID = :SID
ORDER BY 3 DESC

/* buffer / IO stat */
SELECT v.SID, username, s.NAME, v.VALUE
  FROM v$statname s, v$sesstat v, v$session sess
 WHERE s.NAME IN ('consistent gets', 'physical reads')
   AND sess.SID = v.SID
   AND v.statistic# = s.statistic#
   AND sess.SID = :SID
