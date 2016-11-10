SELECT
  TO_CHAR(round(end_interval_time,'HH24'),'hh24:mi') TIME,
  TO_CHAR(end_interval_time, 'DD.MM ')||'Inst'||INSTANCE_NUMBER||
    ' '||event_name AS NAME,
  ROUND ((TIME_WAITED_MICRO                  -LAG (TIME_WAITED_MICRO, 1) over ( partition BY
  EVENT_NAME order by SNAP_ID))              / (TOTAL_WAITS - LAG ( TOTAL_WAITS, 1 ) OVER (
  PARTITION BY event_name ORDER BY snap_id)) / 1000,1 ) AS VALUE
FROM
  DBA_HIST_SYSTEM_EVENT NATURAL JOIN dba_hist_snapshot
WHERE
  EVENT_NAME IN (
    'db file scattered read', 'db file sequential read'
--    ,'log file parallel write', 'log file sync'
                 )
   AND end_interval_time > SYSTIMESTAMP - INTERVAL '14' DAY
   AND TO_CHAR(end_interval_time, 'DAY') like :weekday
   --AND INSTANCE_NUMBER = sys_context('USERENV', 'INSTANCE')
ORDER BY 1,2