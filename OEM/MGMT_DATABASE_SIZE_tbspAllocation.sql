--
-- DB size current
--

-- source DATABASE_SIZE:
 SELECT ROUND(nvl(sum(tablespace_size)/1024/1024/1024,0),2) ALLOCATED_GB,
        ROUND(nvl(sum(tablespace_used_size)/1024/1024/1024,0),2) USED_GB,
        target_guid
FROM mgmt$db_tablespaces group by target_guid


-- pouze DB size
SELECT
    d.database_name,
    round(m.value) as database_size_gb
FROM
         sysman.mgmt$metric_current m
    JOIN sysman.MGMT$DB_DBNINSTANCEINFO d
         ON (m.target_guid = d.target_guid)
WHERE
      m.metric_name = 'DATABASE_SIZE'
  AND m.metric_column in ('ALLOCATED_GB')
  AND m.target_name LIKE 'MCIP%'
;

-- historicka data
SELECT
    to_char(ma.rollup_timestamp,'YYYY-MM-DD') AS "DATE",
    (ma.rollup_timestamp - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000 * 1000000  AS timestamp,
    d.entity_name dbname,
    d.host_name,
    p.PROPERTY_VALUE env_status,
    ma.average as ma_value,
    mu.average as mu_value
FROM
    sysman.MGMT$METRIC_DAILY ma
    JOIN sysman.MGMT$METRIC_DAILY mu on (
           ma.target_guid = mu.target_guid
       AND ma.rollup_timestamp = mu.rollup_timestamp)
    JOIN sysman.EM_MANAGEABLE_ENTITIES d ON (ma.target_guid = d.entity_guid)
    join sysman.MGMT_TARGET_PROPERTIES p on (p.target_guid = d.entity_guid)
WHERE
  d.category_prop_3 = 'DB'
  AND   p.property_name = 'orcl_gtp_lifecycle_status'
  AND   ma.metric_name = 'DATABASE_SIZE'
  AND   ma.metric_column in ('ALLOCATED_GB')
  AND   mu.metric_column in ('USED_GB')
  AND   ma.target_name LIKE 'MDWTB%'
--ORDER BY timestamp, dbname, env_status, metric_name
 ORDER BY timestamp, dbname
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


-- Grafana tablespace
select
     TO_CHAR(t.collection_timestamp,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS TIMESTAMP,
     d.entity_name as DBNAME,
     d.host_name,
     p.PROPERTY_VALUE ENV_STATUS,
     tablespace_name,
     round(tablespace_size/power(1024,2)) as SIZE_MB,
     round(tablespace_used_size/power(1024,2)) AS USED_MB
  from    mgmt$db_tablespaces t
    JOIN sysman.EM_MANAGEABLE_ENTITIES d
      ON (t.target_guid = d.entity_guid)
    JOIN sysman.mgmt_target_properties p
      ON (p.target_guid = d.entity_guid)
 where p.property_name = 'orcl_gtp_lifecycle_status'
    AND d.entity_name = 'MDWTB'
    --and tablespace_name = 'SYSTEM'
;

-- tbspAllocation
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
