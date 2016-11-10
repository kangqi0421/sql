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
		 
-- Database Current Logons Count	
-- Time Series bar Chart	 
SELECT
   metric_column,
   m.rollup_timestamp "date",
   to_number(m.maximum)
FROM
  MGMT$METRIC_HOURLY m
WHERE  1 = 1
  AND target_guid=HEXTORAW(??EMIP_BIND_TARGET_GUID??)
  AND target_type = 'oracle_database'
  AND m.metric_name = 'Database_Resource_Usage'
  AND m.metric_column like 'logons'
  AND column_label like 'Current Logons Count'
  AND m.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND m.rollup_timestamp <= ??EMIP_BIND_END_DATE??
ORDER BY  m.rollup_timestamp