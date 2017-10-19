--
-- FRA
--

-- AVG, MAX
SELECT
   database_name,
   round(avg(redo_value_gb)) avg_redo_gb,
   round(max(redo_value_gb)) max_redo_gb
from (
SELECT
   m.rollup_timestamp,
   d.database_name,
   -- sum per instance per day
   round(sum(m.average)*24*3600/power(1024,3)) redo_value_gb
FROM
  MGMT$METRIC_DAILY m
   JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE
  m.rollup_timestamp > sysdate - interval '1' month
  AND metric_name = 'instance_throughput'
  AND metric_column = 'redosize_ps' --Redo Generated (per second)
  --AND m.target_name like 'BRATB%'
  AND (d.database_name like 'BRAT%' OR d.database_name like 'BRAD%')
group by m.rollup_timestamp, d.database_name
)
group by database_name
order by 1
;

-- redo size za den z metriky redosize_ps
SELECT /* OEM metric daily */
   m.target_name,
   to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "timestamp",
   m.column_label,
   -- redo size per second n�sob�m 24/3600 za cel� den
   round(m.average*24*3600/power(1024,3)) redo_value_gb
FROM
  MGMT$METRIC_DAILY m
WHERE  1 = 1
  AND m.target_name like 'SYMTA%'
  AND metric_name = 'instance_throughput'
  AND metric_column = 'redosize_ps' --Redo Generated (per second)
ORDER BY  m.rollup_timestamp
;


-- FRA size: flash_recovery_area_size
SELECT
    d.database_name, 
--    d.instance_name,
    m.target_guid,
    m.target_name,
    round(m.value/power(1024,3)) as fra_size_gb
FROM
    mgmt$metric_current m
      JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE
      m.metric_name     = 'ha_flashrecovery'
  AND m.metric_column   = 'flash_recovery_area_size'
  AND d.database_name in (
    'BRADA', 'BRADB', 'BRADC', 'BRADD', 'BRATA', 'BRATB', 'BRATC'
  )
--  AND m.target_name like 'SK2%'
order by 1
;



--// FRA disk group space used //--
-- limit pro zapln�n� > 81%
SELECT
    TARGET_NAME,
    column_label,
    key_value,
    to_number(value),
--    collection_timestamp,
    AGGREGATE_TARGET_NAME
  FROM
    SYSMAN.MGMT$METRIC_CURRENT
    INNER JOIN MGMT$TARGET_FLAT_MEMBERS
		ON  (member_target_guid = target_guid)
  WHERE 1=1
--  AND AGGREGATE_TARGET_NAME in ('PRODUKCE')
  AND AGGREGATE_TARGET_TYPE = 'composite'
  AND METRIC_NAME          = 'DiskGroup_Usage'
  AND METRIC_COLUMN        = 'percent_used'
  AND KEY_VALUE LIKE '%FRA'
  and value > 81
  ORDER BY
    to_number(value) DESC;

-- Usable Flash Recovery Area (%)
-- Reclaimable Flash Recovery Area (%)
SELECT
--    collection_timestamp,
    target_name,
    column_label,
    to_number(value)
  FROM
    SYSMAN.MGMT$METRIC_CURRENT
  WHERE
    1=1
  --AND TARGET_TYPE  IN ('rac_database','oracle_database')
  AND METRIC_NAME   = 'ha_flashrecovery'
  --
--  AND METRIC_COLUMN = 'reclaimable_area' and column_label = 'Reclaimable Flash Recovery Area (%)'
  and metric_column = 'usable_area' and column_label = 'Usable Flash Recovery Area (%)'
  --
--  and value < 50  -- limit value
  AND TARGET_NAME LIKE 'BRAD%'
  ORDER BY
    to_number(value) DESC nulls last
;

-- disablovane metriky s nastavenymi thresholdy
SELECT t.target_name,
  t.target_type,
  t.metric_name,
  t.metric_column,
  t.collection_name,
  t.warning_threshold,
  T.CRITICAL_THRESHOLD,
  t.column_label,
  is_enabled,
  frequency_code,
  collection_frequency
FROM mgmt$target_metric_settings t,
     mgmt$target_metric_collections m
WHERE t.target_guid   = m.target_guid
AND t.metric_name     = m.metric_name
AND t.collection_name = m.collection_name
  --and t.target_name like 'CRMTA'  -- konretni db
AND t.TARGET_TYPE      IN ('rac_database','oracle_database') -- pouzedb a rac
AND (warning_threshold <> ' ' OR critical_threshold  <> ' ') -- pouze nastavene thresholdy
AND m.is_enabled        = 0  -- pouze disabled
AND t.metric_name NOT  IN ('alertLog','alertLogStatus','db_alert_log','db_alert_log_status','inst_archFull') --mimo alert.log a FRA na instanci
ORDER BY TARGET_NAME, metric_name, metric_column
;

