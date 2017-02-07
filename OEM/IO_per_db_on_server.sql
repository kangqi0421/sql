-- všechny servery tady v Praze
define server=tordb03

-- I/O Requests (per second) - database
SELECT
   to_char(m.rollup_timestamp,'yyyy-mm-dd hh24:mi:ss') timestamp,
   m.target_name db_name,
   round(m.maximum) "max"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
WHERE m.metric_name = 'instance_throughput'
  -- I/O Requests
  AND m.metric_column = 'iorequests_ps'
  -- IO MB per db on server
  --AND m.metric_column = 'iombs_ps'
  AND m.rollup_timestamp > sysdate - interval '1' DAY
  AND t.host_name in (:hostname)
order by 1


SELECT
   to_char(m.rollup_timestamp,'yyyy-mm-dd hh24:mi:ss') timestamp,   m.target_name,
   round(m.maximum) "max"
--   round(m.average) "avg"
FROM
  MGMT$METRIC_HOURLY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
WHERE m.metric_name = 'instance_throughput' AND m.metric_column = 'iombs_ps'
  AND m.rollup_timestamp > sysdate - interval '1' DAY
  AND t.host_name in (:hostname)
order by 1;


AND m.metric_name = 'instance_throughput' AND m.metric_column = 'iombs_ps'
