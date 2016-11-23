-- všechny servery tady v Praze
define server=tordb03

-- I/O Requests (per second) - database
SELECT 
   -- *
   m.ROLLUP_TIMESTAMP,
   m.target_name,
   round(m.maximum) "max"
--   round(m.average) "avg"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
  --MGMT$METRIC_DAILY m
WHERE m.metric_name = 'instance_throughput' AND m.metric_column = 'iorequests_ps'
  AND m.rollup_timestamp > sysdate - interval '3' DAY
  --AND t.host_name like '&server%'
  AND t.host_name like 'tordb03.vs.csin.cz'
order by 1;

-- IO MB per db on server
SELECT 
   -- *
   m.ROLLUP_TIMESTAMP,
   m.target_name,
   round(m.maximum) "max"
--   round(m.average) "avg"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
  --MGMT$METRIC_DAILY m
WHERE m.metric_name = 'instance_throughput' AND m.metric_column = 'iombs_ps'
  AND m.rollup_timestamp > sysdate - interval '3' DAY
  --AND t.host_name like '&server%'
  AND t.host_name like 'tordb03.vs.csin.cz'
order by 1;


AND m.metric_name = 'instance_throughput' AND m.metric_column = 'iombs_ps'
