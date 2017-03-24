--
-- PIVOT
--

-- database info
select t.target_guid, t.target_name,
       db_name, dbversion, env_status,
       DECODE(is_rac, 'YES', 'Y', 'NO', 'N', is_rac) is_rac,
       -- pokud je db v clsteru, vrat scanName, jinak server name
       NVL2(cluster_name, scanName, server_name) server_name,
       port
  from MGMT$TARGET_PROPERTIES
  PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
    'DBName' as db_name,
    'DBVersion' as dbversion,
    'orcl_gtp_lifecycle_status' as env_status,
    'RACOption' as is_rac,
    'ClusterName' as cluster_name,
    'MachineName' as server_name,
    'Port' as port
    )) p
  -- pouze DB bez RAC instance
  JOIN MGMT$TARGET t on (p.target_guid = t.target_guid)
  -- join scanName dle clusterName
  LEFT JOIN (select target_name, property_value scanName
         from MGMT$TARGET_PROPERTIES
        where property_name = 'scanName') s
    ON p.cluster_name = s.target_name
  -- pouze DB bez RAC instance
WHERE t.TYPE_QUALIFIER3 = 'DB'
ORDER BY DB_NAME
;

-- memory parameters --
with pivot_data as
(
select sys_context('USERENV', 'INSTANCE_NAME') as inst, name, ceil(value/1048576) as mb from v$parameter
 )
SELECT *
FROM pivot_data PIVOT (max(mb) for name in ('memory_target', 'sga_target', 'pga_aggregate_target') )
order by 1
/


--// spec utilization //--

WITH pivot_data
     AS (SELECT substr(hostname,1,INSTR (hostname, '.', 1)-1) hostname,
             datetime_hourly, spec_util
           FROM ovo_hourly
          WHERE datetime_hourly BETWEEN DATE '2011-12-01'
                                    AND DATE '2012-01-01')
  SELECT *
    FROM pivot_data PIVOT (MAX (spec_util)
                    FOR hostname
                    IN ('amldb1', 'apscdbp1', 'rdbp1', 'apscdbp2'))
ORDER BY 1