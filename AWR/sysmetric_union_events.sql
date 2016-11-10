SELECT   
    ROUND(CAST(end_interval_time AS DATE), 'MI') AS end_time,
    name,
    value
  FROM
    (
    WITH EVENTS AS
        (
          SELECT   snap_id,
              instance_number,
              event_name AS NAME,
              ROUND ((TIME_WAITED_MICRO                  -LAG (TIME_WAITED_MICRO, 1) over (
              partition BY EVENT_NAME order by SNAP_ID)) / (TOTAL_WAITS - LAG (
              TOTAL_WAITS, 1 ) OVER (PARTITION BY event_name ORDER BY snap_id))
              / 1000,1 ) AS VALUE
            FROM DBA_HIST_SYSTEM_EVENT
            WHERE EVENT_NAME IN ( 'log file sync'
              --'log file parallel write'
              --'LGWR-LNS wait on channel'
              )
              AND INSTANCE_NUMBER = sys_context('USERENV', 'INSTANCE')
        )
        ,
        SYSMETRIC AS
        (
          SELECT   snap_id,
              instance_number,
              metric_name AS name,
              average     AS value -- AVERAGE --
            FROM dba_hist_sysmetric_summary
            WHERE instance_number = sys_context('USERENV', 'INSTANCE') --
              -- current
              AND metric_name IN ( 'User Transaction Per Sec' )
        )
      SELECT   snap_id,
          name,
          value
        FROM SYSMETRIC
      UNION
      SELECT   snap_id,
          NAME,
          value
        FROM EVENTS
    )
    NATURAL
  JOIN dba_hist_snapshot
  WHERE end_interval_time > TRUNC(sysdate - :DNI)
   ORDER BY end_interval_time, name
   
  ;