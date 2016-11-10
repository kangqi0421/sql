---
EVENTS
---

--ALTER SESSION SET NLS_TERRITORY = "CZECH REPUBLIC";
--ALTER SESSION SET nls_date_format = 'dd.mm.yyyy hh24:mi';
ALTER session SET NLS_NUMERIC_CHARACTERS = ', ';

-- log file sync
-- log file parallel write
-- db file sequential read
-- db file scattered read

-- header
-- Date;db file scattered read [ms];db file sequential read [ms];log file parallel write [ms];log file sync [ms];

SELECT end_time || ';'|| listagg (ROUND (avg_wait, 2), ';') WITHIN GROUP (ORDER BY event_name) as data
  FROM
  (
select
    CAST(end_interval_time AS DATE) as end_time,
    SNAP_ID,
    event_name,
    event_id,
    --  ROUND((time_waited_micro-LAG (time_waited_micro, 1) OVER (PARTITION BY event_name ORDER BY snap_id))/1000000) "wait time [s]",
    ROUND ((TIME_WAITED_MICRO-LAG (TIME_WAITED_MICRO, 1) over (partition by EVENT_NAME order by SNAP_ID))/nullif(
          (total_waits - LAG (total_waits, 1) OVER (PARTITION BY event_name ORDER BY snap_id)), 0)/1000,1) as avg_wait
    --    time_waited_micro/nullif(total_waits,0) avg_wait_micro
  FROM DBA_HIST_SYSTEM_EVENT NATURAL JOIN DBA_HIST_SNAPSHOT
  where EVENT_NAME in (
--                    'db file scattered read',
                    'db file sequential read',
                    'log file parallel write',
                    'log file sync'
                    )
  and   instance_number = sys_context('USERENV', 'INSTANCE')
      AND (TO_CHAR (end_interval_time, 'MI') > '55' OR TO_CHAR (end_interval_time, 'MI') < '05')   --<< pouze cela hodina
      AND end_interval_time > trunc(sysdate - 7)
  ORDER BY end_interval_time, event_name
  )
  where avg_wait is not null
  GROUP BY end_time
  ORDER BY end_time;

-- porovnání pouze v noci
-- ten samý SQL dotaz, akorát obalený na HH24
set lines 80
col end_time for a20
col event_name for a25
col "wait time [s]" for 99999

select * from (
select
    CAST(end_interval_time AS DATE) as end_time,
    event_name,
--    event_id,
    ROUND((time_waited_micro-LAG (time_waited_micro, 1) OVER (PARTITION BY event_name ORDER BY snap_id))/1000000) "wait time [s]",
    ROUND ((TIME_WAITED_MICRO-LAG (TIME_WAITED_MICRO, 1) over (partition by EVENT_NAME order by SNAP_ID))/nullif(
          (total_waits - LAG (total_waits, 1) OVER (PARTITION BY event_name ORDER BY snap_id)), 0)/1000,1) as avg_wait
    --    time_waited_micro/nullif(total_waits,0) avg_wait_micro
  FROM DBA_HIST_SYSTEM_EVENT NATURAL JOIN DBA_HIST_SNAPSHOT
  where EVENT_NAME in (
--                    'db file scattered read',
                    'db file sequential read'
--                    'log file parallel write',
--                    'log file sync'
                    )
  and   instance_number = sys_context('USERENV', 'INSTANCE')
--      AND (TO_CHAR (end_interval_time, 'MI') > '55' OR TO_CHAR (end_interval_time, 'MI') < '05')   --<< pouze cela hodina
      --
      AND end_interval_time > trunc(sysdate - 3)
  ORDER BY end_interval_time, event_name
)
  WHERE
   TO_CHAR (end_time, 'HH24') between 01 and 01  -- pouze v noci
;
