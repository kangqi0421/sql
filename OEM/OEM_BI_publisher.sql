--
-- OEM BI Publisher
--
https://oem12-m.vs.csin.cz:1161/xmlpserver/

-- server metrics
 where metric_name in ('Load','DiskActivitySummary')
   AND metric_column in ('cpuUtil', 'usedLogicalMemoryPct','totiosmade')


-- DB metrics
  metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
  metric_name = 'memory_usage' AND metric_column = 'total_memory'
  iorequests_ps
  iombs_ps

-- DB NAME list
select d.target_name db_name,
       host
  FROM MGMT$DB_DBNINSTANCEINFO d
 WHERE host like 'dordb%'
ORDER by d.target_name
;

-- host name
select T.HOST_NAME
  from MGMT_TARGETS t
 WHERE t.target_type IN ('host')
   AND REGEXP_LIKE(host_name, 'z?(t|d|p|b)o(r)?db(rca)?[[:digit:]]+.vs.csin.cz')
ORDER BY 1
;


-- Average Maximum value
select
  target_name,
  db_metric,
  round(avg(value),1) Average,
  round(max(value),1) Maximum
from (
...
)
group by  target_name, db_metric
order by  target_name, db_metric

--
-- Data Model
--
-- CPU_MEM_server_daily
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   substr(m.target_name, 1, instr(m.target_name, '.')-1) target_name,
   metric_column server_metric,
   ROUND(m.maximum) value
 FROM
   mgmt$metric_daily m
     join MGMT$OS_HW_SUMMARY h
    on (m.target_name = h.host_name)
 where metric_name in ('Load')
   AND metric_column in ('cpuUtil', 'usedLogicalMemoryPct')
   AND m.target_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

-- G2: db_daily
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   m.target_name,
   metric_column db_metric,
   ROUND(m.maximum) value
 FROM
   mgmt$metric_daily m JOIN MGMT$DB_DBNINSTANCEINFO d
     ON (m.target_guid = d.target_guid)
 where metric_name in ( 'memory_usage', 'instance_efficiency')
   AND metric_column in ('cpuusage_ps', 'total_memory')
   AND d.host_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, m.maximum
;

-- DB daily vcetne DB size
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   m.target_name,
   metric_column db_metric,
   case metric_column
     when 'cpuusage_ps' then ROUND(m.maximum/100,2)
     when 'total_memory' then ROUND(m.maximum/1024)
   else
     ROUND(m.maximum)
   end value
 FROM
   mgmt$metric_daily m JOIN MGMT$DB_DBNINSTANCEINFO d
     ON (m.target_guid = d.target_guid)
 where metric_name in
     ('instance_efficiency', 'memory_usage', 'DATABASE_SIZE','instance_throughput')
   AND metric_column in
     ('cpuusage_ps', 'total_memory','ALLOCATED_GB')
   and d.target_name in (:db_name)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name
;

-- server_daily_agg
select
  target_name,
  server_metric,
  round(avg(value),1) Average,
  round(max(value),1) Maximum
from (
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   substr(m.target_name, 1, instr(m.target_name, '.')-1) target_name,
   metric_column server_metric,
   ROUND(m.maximum) value
 FROM
   mgmt$metric_daily m
where metric_name in ('Load')
   AND metric_column in ('cpuUtil', 'usedLogicalMemoryPct')
   AND m.target_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
)
group by  target_name, server_metric
order by  target_name, server_metric

-- IO per DB
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

-- IO hourly
SELECT
   to_char(m.rollup_timestamp,'yyyy-mm-dd hh24:mi:ss') timestamp,
   m.target_name db_name,
   round(m.maximum) "max"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
WHERE m.metric_name = 'instance_throughput'
  -- I/O Requests
  AND m.metric_column = :metric_name
  AND m.rollup_timestamp > sysdate - interval '1' DAY
  AND t.host_name in (:hostname)
order by 1