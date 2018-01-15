-- DB size current
-- pouze DB
SELECT
    d.entity_name dbname,
    round(m.value) as database_size_gb
FROM
    sysman.mgmt$metric_current m
    JOIN sysman.EM_MANAGEABLE_ENTITIES d ON (
        m.target_guid = d.entity_guid
    )
WHERE
  d.category_prop_3 = 'DB'
  AND m.metric_name = 'DATABASE_SIZE'
  AND m.metric_column in ('ALLOCATED_GB', 'USED_GB')
  AND m.target_name LIKE 'MCIP%'
;


-- varianta s mgmt$db_dbninstanceinfo a GROUP BY
SELECT
    d.database_name dbname,
    round(max(m.value)) as database_size_gb
FROM
    mgmt$metric_current m
    JOIN mgmt$db_dbninstanceinfo d ON (
        m.target_guid = d.target_guid
    )
WHERE m.metric_name = 'DATABASE_SIZE'
  AND m.metric_column = 'ALLOCATED_GB'
-- AND m.metric_column in ('ALLOCATED_GB', 'USED_GB')
  AND m.target_name LIKE 'MCIP%'
GROUP BY d.database_name
;



-- Database size
SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
   d.DATABASE_NAME db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value tablespace,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN MGMT$DB_DBNINSTANCEINFO d ON (m.target_guid = d.target_guid)
WHERE 1=1
  -- AND m.target_name like 'CPTDA'
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column in ('spaceUsed', 'spaceAllocated')
ORDER by 1, 2
;

-- DB size Grafana
SELECT
     TO_CHAR(val.collection_time,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS time,
     c.entity_name AS dbname,
     c.entity_type,
     p.PROPERTY_VALUE env_status,
     k.key_part_1 AS tbs_name,
     t.host_name,
     c.metric_column_name,
     c.metric_column_label,
     c.unit,
     sys_op_ceg(val.met_values,c.column_index) AS value
FROM
     sysman.em_metric_items i
     join sysman.gc_metric_columns_target c on i.metric_group_id = c.metric_group_id
     join sysman.em_metric_values val on i.metric_item_id = val.metric_item_id
     join sysman.em_metric_keys k on i.metric_key_id = k.metric_key_id
     join sysman.em_targets t on t.target_guid = c.entity_guid
     join sysman.MGMT_TARGET_PROPERTIES p on p.target_guid = c.entity_guid
WHERE
     c.METRIC_GROUP_NAME = 'DATABASE_SIZE'
     AND   p.property_name = 'orcl_gtp_lifecycle_status'
     AND   i.target_guid = c.entity_guid
     AND   c.column_type = 0
     AND   c.data_column_type = 0
     AND   i.last_collection_time = val.collection_time
     AND   c.entity_guid NOT IN (
         SELECT
             dest_me_guid
         FROM
             sysman.gc$assoc_instances a
         WHERE
             a.assoc_type = 'cluster_contains'
     )
ORDER BY 1, 2, 4;

-- SQLDev report OEM - space report
SELECT
    -- OEM metric daily
    trunc(m.rollup_timestamp) "date",
    m.metric_column "size_gb",
    ROUND(m.average,1) value
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
    AND m.target_name LIKE :db
    AND m.metric_name          ='DATABASE_SIZE'
    AND m.metric_column in ('ALLOCATED_GB', 'USED_GB')
    AND m.rollup_timestamp > sysdate - interval '7' month
  ORDER BY m.rollup_timestamp ASC ;

-- Database Space Usage - OEM graph
SELECT
         ROUND(SUM(t.tablespace_size/1024/1024/1024), 2) AS ALLOC_GB,
         ROUND(SUM(t.tablespace_used_size/1024/1024/1024), 2) AS USED_GB,
         ROUND(SUM((t.tablespace_size - tablespace_used_size)/1024/1024/1024), 2) AS ALLOC_FREE_GB
       FROM
         mgmt$db_tablespaces t,
         (SELECT target_guid
            FROM mgmt$target
            WHERE target_guid=HEXTORAW(??EMIP_BIND_TARGET_GUID??) AND
            (target_type='rac_database' OR
            (target_type='oracle_database' AND TYPE_QUALIFIER3 != 'RACINST'))) tg
       WHERE
         t.target_guid=tg.target_guid
;


--// Trocha analytickych funkci pro zobrazeni narustu za poslednich N dni //-

ALTER session SET NLS_NUMERIC_CHARACTERS = ', ';

define target_name = "'CPSP'"
define pocet_dni = "add_months(sysdate,-1)"     //poslední měsíc

col target_name for a10

SELECT target_name,
       metric_column,
       rollup_timestamp,
       average,
       average - LAG (average) OVER (PARTITION BY metric_column ORDER BY rollup_timestamp)  diff
  FROM (SELECT target_name,
               metric_column,
               rollup_timestamp,
               average,
               ROW_NUMBER () OVER (PARTITION BY metric_column ORDER BY rollup_timestamp ASC) RN1,
               ROW_NUMBER () OVER (PARTITION BY metric_column ORDER BY rollup_timestamp DESC) RN2
          FROM mgmt$metric_daily a
         WHERE     metric_column IN ('ALLOCATED_GB', 'USED_GB')
               AND target_name in (&target_name)
               AND rollup_timestamp > &pocet_dni)
 WHERE RN1 = 1 OR RN2 = 1;


SELECT   m.rollup_timestamp AS rollup_timestamp,
         m.target_name, m.metric_column,
         m.average AS VALUE
    FROM mgmt$metric_daily m
   WHERE 1 = 1
--         AND m.target_name in (&target_name)
--         AND REGEXP_LIKE(m.target_name, '^BRA[TD][ABCD]_.*1')
         AND m.target_name in (
         -- pouze DB targety
         select target_name from MGMT_TARGETS
             where Category_Prop_3 = 'DB'
              AND Host_Name like '%ordb04%'
              and target_name in ('CR','EPAKUAT1','FATAL','MASTER','PARDE','PARDEDU','PARDINT','PARDPRS','PARDSYS','REVP','REVPK')
         )
         AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( 3, 'MONTH' )
         AND m.target_type in (
            'rac_database',
            'oracle_database')
         AND m.metric_name = 'DATABASE_SIZE'
         AND (m.metric_column = 'ALLOCATED_GB'
             --OR t.metric_column = 'USED_GB'
              )
ORDER BY m.rollup_timestamp, m.metric_column, m.target_name
;