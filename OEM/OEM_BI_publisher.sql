--
-- OEM BI Publisher
--
--  https://oem12-m.vs.csin.cz:1161/xmlpserver/

-- metrics
  AND metric_column = 'cpuUtil'
  AND metric_column = 'memUsedPct'
  metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
  metric_name = 'memory_usage' AND metric_column = 'total_memory'
  iorequests_ps
  iombs_ps

-- DB NAME list
select d.target_name db_name
  FROM MGMT$DB_DBNINSTANCEINFO d
ORDER by d.target_name;

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
   AND metric_column = 'cpuUtil'
   AND m.target_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

-- CPU per db on server
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   m.target_name,
   ROUND(m.maximum/100, 2) vcpu
 FROM
   mgmt$metric_daily m JOIN MGMT$DB_DBNINSTANCEINFO d
     ON (m.target_guid = d.target_guid)
 where metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
   AND d.host_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

-- MEM per db on server
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   m.target_name,
   ROUND(m.maximum) mem_mb
 FROM
   mgmt$metric_daily m JOIN MGMT$DB_DBNINSTANCEINFO d
     ON (m.target_guid = d.target_guid)
 where metric_name = 'memory_usage' AND metric_column = 'total_memory'
   AND d.host_name in (:hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name

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