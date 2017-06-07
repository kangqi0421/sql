--
-- FRA
--

-- AVG, MAX
SELECT
   target_name,
   target_guid,
   round(avg(redo_value_gb)) avg_redo_gb,
   round(max(redo_value_gb)) max_redo_gb
from (
SELECT
   m.target_name,
   m.target_guid,
   --to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "timestamp",
   --m.column_label,
   -- redo size per second násobím 24/3600 za celý den
   round(m.average*24*3600/power(1024,3)) redo_value_gb
FROM
  MGMT$METRIC_DAILY m
WHERE  1 = 1
  AND metric_name = 'instance_throughput'
  AND metric_column = 'redosize_ps' --Redo Generated (per second)
  AND m.target_name like 'SYMPK%'
  AND m.target_name in ('BRAEA_dordb04.vs.csin.cz', 'BRATB', 'BRATB_BRATB2', 'BRATB_BRATB1', 'BRATC', 'BRATC_BRATC2', 'BRATC_BRATC1', 'CPSEA_dordb04.vs.csin.cz', 'CPSTINT_CPSTINT2', 'CPSTINT_CPSTINT1', 'CPSTINT', 'CPSTPRS_CPSTPRS2', 'CPSTPRS', 'CPSTPRS_CPSTPRS1', 'CRMRA', 'CRMTB', 'CRMTB_tordb01', 'CRMTC', 'CRMTC_tordb02', 'MCITINT', 'MCITINT_MCITINT2', 'MCITINT_MCITINT1', 'MCITPRS', 'MCITPRS_MCITPRS2', 'MCITPRS_MCITPRS1', 'SYMPK', 'SYMTA_tordb02.vs.csin.cz', 'TS0O', 'WBLINT', 'WBLINT_WBLINT1', 'WBLINT_WBLINT2', 'WBLPRS', 'WBLPRS_WBLPRS2', 'WBLPRS_WBLPRS1')
)
group by    target_name, target_guid
;

-- redo size za den z metriky redosize_ps
SELECT /* OEM metric daily */
   m.target_name,
   to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "timestamp",
   m.column_label,
   -- redo size per second násobím 24/3600 za celý den
   round(m.average*24*3600/power(1024,3)) redo_value_gb
FROM
  MGMT$METRIC_DAILY m
WHERE  1 = 1
  AND m.target_name like 'SYMTA%'
  AND metric_name = 'instance_throughput'
  AND metric_column = 'redosize_ps' --Redo Generated (per second)
ORDER BY  m.rollup_timestamp
;


-- FRA size
SELECT
    f.target_guid,
    f.target_name,
    round(f.value/power(1024,3)) as fra_size_gb
FROM
    mgmt$metric_current f
WHERE
      f.metric_name     = 'ha_flashrecovery'
  AND f.metric_column   = 'flash_recovery_area_size'
  AND f.target_name like 'SYMPK%'
;



--// FRA disk group space used //--
-- limit pro zaplnìní > 81%
SELECT
    TARGET_NAME,
    column_label,
    key_value,
    to_number(value),
--    collection_timestamp,
    AGGREGATE_TARGET_NAME
  FROM
    SYSMAN.MGMT$METRIC_CURRENT INNER JOIN MGMT$TARGET_FLAT_MEMBERS
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
  and value < 50  -- limit value
--  AND TARGET_NAME LIKE 'CTLRP'
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

