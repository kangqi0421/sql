--
-- Sysmetric Oracle stats
--

 - 'I/O Megabytes per Second' nepoužívat, ukazuje nesmysly - bug 9505995
 - 'I/O Requests per Second' je v pohodì
 - Network Traffic Volume Per Sec - public network traffic per second

SGA/PGA
 - Buffer Cache Hit Ratio
 - Total PGA Allocated

--// vyber zajimavych metrik //--
select * from V$METRICNAME 
  where metric_name like '%Block%'
  order by metric_name;

select * from v$sysmetric
  where metric_name like '%multi%'
 order by metric_name;
 
select * from V$SYSMETRIC_SUMMARY
  where metric_name like '%Read%'
 order by metric_name; 

-- header
Time;Average Active Sessions;CPU Usage Per Sec[%];CPU Usage Per Tx;Logons [-];OS load[-];DB Time [sec];DB Block Changes Per Sec;CPU util [%];
read MBPS[MB/s];write MBPS[MB/s];IOPS [-];network [bytes/s];redo size [bytes/s];
Response Time per tx [cs/tx];SQL Service Resp time [cs/call];User transaction [tps];

-- NLS settings
--ALTER SESSION SET NLS_TERRITORY = "CZECH REPUBLIC";
ALTER SESSION SET nls_date_format = 'dd.mm.yyyy hh24:mi';
ALTER session SET NLS_NUMERIC_CHARACTERS = ', ';

define days=31

SELECT end_time || ';' ||
       listagg (ROUND (value, 2), ';')
               WITHIN GROUP (ORDER BY metric_name) --OVER (PARTITION BY instance_number)
               as data
from (
--
/*
WITH
  -- definice rozsahu AWR id
  range AS
  (
  --
    SELECT   start_time start_time, nvl(end_time, sysdate) end_time
       FROM dba_workload_replays
       WHERE start_time =
    (
      SELECT   MAX(start_time)
        FROM dba_workload_replays
--        WHERE status = 'COMPLETED'
    )
  --
  )
*/
;

SELECT   ROUND(CAST(s.end_time AS DATE), 'MI') as end_time,  --round to hour, cast to date
         -- to_char(s.end_time, 'HH24'),
--         instance_number,
         metric_name,
--         maxval as value,     -- MAX --
         average as value  -- AVERAGE --
         --CASE
         --   WHEN metric_unit LIKE '%Bytes%' THEN ROUND (average / 1048576,2)
         --   ELSE ROUND (average,2)
         --END
         --   VALUE,
--         metric_unit
    FROM dba_hist_sysmetric_summary s
         --, range e
	 WHERE
       1=1
--       AND instance_number = sys_context('USERENV', 'INSTANCE')   -- current instance
       AND instance_number = 1
--         AND (TO_CHAR (END_TIME, 'MI') > '55' OR TO_CHAR (END_TIME, 'MI') < '05')   --<< pouze cela hodina
      AND to_char(s.end_time, 'HH24') between 18 and 23
         AND end_time > trunc(sysdate - &days)
--       and snap_id in (38489, 38509, 38513)
--		 AND end_time between timestamp'2014-03-31 00:00:00' AND timestamp'2014-04-04 00:00:00'
--       AND s.end_time >= e.start_time
--       AND s.end_time <  e.end_time
       AND metric_name IN  (
--					     'Average Active Sessions',
--                 'CPU Usage Per Sec',
--                 'CPU Usage Per Txn',
--                 'Current Logons Count',
--      				   'Current OS Load',
                 'Database Time Per Sec'
--                 'DB Block Changes Per Sec',
--                 'Host CPU Utilization (%)',
--        				 'I/O Requests per Second',
--                 'Physical Read Total Bytes Per Sec',
--                 'Physical Write Total Bytes Per Sec',
--                 'Network Traffic Volume Per Sec',	-- public network traffic, bytes per sec
--                 'Redo Generated Per Sec',
--                 'Redo Generated Per Txn',
--                 'Response Time Per Txn',
--                 'SQL Service Response Time',
--                 'User Calls Per Sec',
--                 'User Transaction Per Sec'
--                 'User Commits Per Sec' */
           -- Buffer cache stats
--                 'Buffer Cache Hit Ratio',
--                 'Total PGA Allocated'
--                 'Shared Pool Free %'
                 )
ORDER BY end_time , metric_name, instance_number
;

)
group by end_time
ORDER BY end_time
;
