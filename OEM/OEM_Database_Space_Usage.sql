-- DB size current
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
  AND m.target_name LIKE 'MCIP%'
GROUP BY d.database_name
;

-- SQLDev report
SELECT
    /* OEM metric daily */
    --   m.*,
    trunc(m.rollup_timestamp) "DATE",
    m.metric_column "SPACE",
    ROUND(m.average,1) value
  FROM MGMT$METRIC_DAILY m
  WHERE 1 = 1
    AND m.target_name LIKE 'CRMP%'
    --  and m.target_name not like '%.cc.%'  -- nechci Viden
    -- Tablespace Allocated Space (MB)
    AND m.metric_name          ='DATABASE_SIZE'
    AND (m.metric_column   ='ALLOCATED_GB'
    OR m.metric_column     ='USED_GB')
--    AND m.rollup_timestamp > sysdate - 14
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