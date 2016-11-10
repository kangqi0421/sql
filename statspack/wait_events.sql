SELECT TO_CHAR (se.snap_time, 'dd.mm.yyyy hh24:mi') AS time,
       waits,
       time / 1000000 "wait time [s]",
       ROUND (TIME / WAITS / 1000) "avg wait time [ms]"
  FROM perfstat.events se
 WHERE se.event = 'log file sync' AND se.snap_time >= TRUNC (SYSDATE - 1)