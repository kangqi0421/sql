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

