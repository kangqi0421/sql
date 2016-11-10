Bar Chart
SQLRight
Value
400
300

-- metriky
 AND metric_name in ('Load','DiskActivitySummary')
 and metric_column in ('cpuUtil', 'memUsedPct','maxavserv','totiosmade')
 AND rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )


-- OEM CPU Prod
with cpu_util as
(
select
   REPLACE(c.hostname,'ordb') hostname,
   a.rollup_timestamp,
   a.average*c.cpu_count/100 AVG_CPU
 FROM
   mgmt$metric_daily a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
  AND a.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND a.rollup_timestamp <= ??EMIP_BIND_END_DATE??
 AND REGEXP_LIKE(a.target_name, '^[pb]ordb0[0-9].vs.csin.cz')
)
select hostname, avg(AVG_CPU) CPU_AVG_UTIL
  from cpu_util
group by hostname
order by substr(hostname,1,1)||substr(hostname,-1,2)
;

-- MGMT$METRIC_DAILY
SELECT
    TO_CHAR(m.rollup_timestamp,'dd.mm.yyyy') "DATE",
    target_name,
    ROUND(average,2) "Average util [%]"
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
--    AND REGEXP_LIKE(m.target_name, '^[pb]ordb0[0-4].vs.csin.cz')
--    AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
--    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND REGEXP_LIKE(m.target_name, :SERVER)
    AND m.target_type      = 'host'
    AND metric_name        = :METRIC_NAME
    AND metric_column      = :METRIC_COLUMN
    AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
  ORDER BY m.rollup_timestamp, m.target_name


-- Hourly daily sysdate - 7
SELECT   TO_CHAR(m.rollup_timestamp,'dd.mm.yyyy') "DT",
    target_name,
    --ROUND(average,2) "CPU util [%]"
    ROUND(maximum,2) "CPU util [%]"
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
    -- OEM Linux Oracle Farma PREPROD/PROD
    AND REGEXP_LIKE(m.target_name, :SERVER)
--    AND REGEXP_LIKE(m.target_name, '^[pb]ordb0[0-4].vs.csin.cz')
--    AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
--    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND m.target_type IN ( 'host')
    AND metric_name        = 'Load'
    AND metric_column      = 'cpuUtil'
    --AND average > 5
    AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
  ORDER BY m.rollup_timestamp, m.target_name

-- Average/maximum daily
SELECT   TO_CHAR(m.rollup_timestamp,'dd.mm.yyyy') "DT",
    target_name,
    --ROUND(average,2) "CPU util [%]"
    ROUND(maximum,2) "CPU util [%]"
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
    -- OEM Linux Oracle Farma PREPROD/PROD
    AND REGEXP_LIKE(m.target_name, 'z(p|b)ordb0[0-4].vs.csin.cz')
    -- AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- OEM LOF test
--    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND m.target_type IN ( 'host')
    AND metric_name        = 'Load'
    AND metric_column      = 'cpuUtil'
    --AND average > 5
    AND m.rollup_timestamp > systimestamp - interval '3' month
  ORDER BY m.rollup_timestamp, m.target_name
;

-- mesicni summary
SELECT TO_CHAR( trunc(m.rollup_timestamp,'mm'), 'dd.mm.yyyy') "DT",
    target_name,
    --ROUND(average,2) "CPU util [%]"
    round(avg(average), 2) "avg CPU util [%]"
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
    -- OEM Linux Oracle Farma PREPROD/PROD
    AND REGEXP_LIKE(m.target_name, 'z(p|b)ordb0[0-4].vs.csin.cz')
    -- AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- OEM LOF test
--    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND m.target_type IN ( 'host')
    AND metric_name        = 'Load'
    AND metric_column      = 'cpuUtil'
    --AND average > 5
    AND m.rollup_timestamp > systimestamp - interval '4' month
 group by  trunc(m.rollup_timestamp,'mm'),  target_name
  ORDER BY DT, target_name
;