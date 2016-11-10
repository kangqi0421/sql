--
-- SYSTAT union EVENTS
--

ALTER session SET NLS_NUMERIC_CHARACTERS = ', ';

-- CSV
-- date; log file parallel write [ms]; log file sync [ms]; redo size [bytes/s];user commits [tx/s];
SELECT   
--   *
   TO_CHAR (END_INTERVAL_TIME, 'dd.mm.yyyy hh24:mi') || ';' || 
      LISTAGG (value, ';') WITHIN GROUP (ORDER BY name)
  FROM
    (
    WITH SYSTAT AS
        (
          SELECT   END_INTERVAL_TIME,
              STAT_NAME NAME,
              ROUND ( delta_value              / to_number( EXTRACT (DAY FROM delta_time) *
              86400                            + EXTRACT (HOUR FROM delta_time) * 3600 +
              EXTRACT (MINUTE FROM DELTA_TIME) * 60 + extract (second FROM
              delta_time)), 1) AS VALUE
            FROM
              (
                SELECT   end_interval_time,
                    STAT_NAME,
                    end_interval_time - LAG (end_interval_time, 1) OVER (PARTITION by stat_name ORDER BY SNAP_ID) DELTA_TIME,
                    VALUE - LAG (VALUE, 1, VALUE) OVER (PARTITION by stat_name ORDER BY snap_id)
                    delta_value
                  FROM dba_hist_sysstat NATURAL  JOIN dba_hist_snapshot
                  WHERE INSTANCE_NUMBER = SYS_CONTEXT('USERENV', 'INSTANCE')
                  AND stat_name         in (
                                'redo size',
                                'user commits')
              )
        )
        ,
        EVENTS AS
        (
          SELECT   END_INTERVAL_TIME,
              event_name AS NAME,
              ROUND ((TIME_WAITED_MICRO                  -LAG (TIME_WAITED_MICRO, 1) over (
              partition BY EVENT_NAME order by SNAP_ID)) / (TOTAL_WAITS - LAG (
              TOTAL_WAITS, 1 ) OVER (PARTITION BY event_name ORDER BY snap_id))
              /1000,1 ) AS VALUE
            FROM DBA_HIST_SYSTEM_EVENT NATURAL JOIN DBA_HIST_SNAPSHOT
            WHERE EVENT_NAME   IN ( 
					'log file sync', 
					'log file parallel write'
					--'LGWR-LNS wait on channel'
					)
            AND INSTANCE_NUMBER = sys_context('USERENV', 'INSTANCE')
        )
      SELECT   END_INTERVAL_TIME,
          name,
          value
        FROM SYSTAT
       WHERE VALUE > 0  -- nezajímají mì restarty DB
      UNION
      SELECT   END_INTERVAL_TIME,
          NAME,
          value
        FROM EVENTS
      order by  END_INTERVAL_TIME, name 
    )
  WHERE VALUE IS NOT NULL  -- vyhod prvni snimek
      AND end_interval_time > trunc(sysdate - &days)    -- posledních N dni
--      AND END_INTERVAL_TIME BETWEEN TO_DATE('31.01.2014 14:00:00','dd.mm.yyyy hh24:mi:ss')
--								AND to_date('31.01.2014 15:30:00','dd.mm.yyyy hh24:mi:ss')
  GROUP BY END_INTERVAL_TIME
  ORDER BY END_INTERVAL_TIME;