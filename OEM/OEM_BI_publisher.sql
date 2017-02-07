
-- CPU nebo MEM
   AND metric_column = 'memUsedPct'
   AND  metric_column = 'cpuUtil'

-- host name
select T.HOST_NAME
  from MGMT_TARGETS t
 WHERE t.target_type IN ('host')
   AND REGEXP_LIKE(host_name, 'z?(t|d|p|b)o(r)?db(rca)?[[:digit:]]+.vs.csin.cz')
ORDER BY 1

--
select T.HOST_NAME DBNAME
  from MGMT_TARGETS t
 WHERE t.target_type IN ('host')
   AND REGEXP_LIKE(host_name, 'z?(t|d|p|b)o(r)?db(rca)?[[:digit:]]+.vs.csin.cz')
ORDER BY 1


-- CPU, MEM utilization
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   substr(m.target_name, 1, instr(m.target_name, '.')-1) target_name,
   ROUND(m.maximum) util
 FROM
   mgmt$metric_daily m
     join MGMT$OS_HW_SUMMARY h
    on (m.target_name = h.host_name)
 where metric_name = 'Load'
   AND metric_column = :metric
   AND m.target_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

-- CPU per db
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   target_name,
   ROUND(m.maximum) util
 FROM
   mgmt$metric_daily m
 where metric_name = 'instance_efficiency'
   AND metric_column = 'cpuusage_ps'
   AND m.target_name in (:db_name)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

-- IO
SELECT
   to_char(m.rollup_timestamp,'yyyy-mm-dd hh24:mi:ss') timestamp,
   m.target_name db_name,
   round(m.maximum) "io_value"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t
    on (t.TARGET_GUID = m.target_guid)
WHERE m.metric_name = 'instance_throughput'
  -- I/O Requests
  AND m.metric_column = :io_metric_name
  AND m.rollup_timestamp > sysdate - interval '7' DAY
  AND t.host_name in (:hostname)
order by 1