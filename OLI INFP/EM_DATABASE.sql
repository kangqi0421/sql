--------------------------------------------------------
--  DDL for View EM_DATABASE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DASHBOARD"."EM_DATABASE" ("EM_GUID", "TARGET_NAME", "DBNAME", "AVAILABILITY", "LOG_MODE", "CHARACTERSET", "SL_MIN", "DBVERSION", "ENV_STATUS", "RAC", "SLA", "CONNECT_DESCRIPTOR", "SERVER_NAME", "PORT", "HOST_NAME", "PLATFORM", "DB_SIZE_MB", "DB_LOG_SIZE_MB", "ASM_DISKGROUP") AS
  select
       t.target_guid em_guid,
       t.target_name,
       database_name dbname,
       -- availability short na UP a DOWN
       decode(a.availability_status_code, 0, 'DOWN', 1, 'UP', 'UNKNOWN') availability,
       decode(log_mode, 'ARCHIVELOG', 'true', 'false') log_mode,
       characterset,
       substr(d.supplemental_log_data_min, 1, 1) SL_MIN,
       dbversion, env_status,
       decode(substr(rac, 1, 1), 'Y', 'true', 'false') rac,
       -- SLA
       CASE
         -- produkce v RAC clusteru = Platinum
         when (rac = 'YES' and env_status = 'Production')
              then 'Platinum'
         -- produkce v A/P clusteru = Gold
         when (rac = 'NO' and env_status = 'Production')
              then 'Gold'
         -- vše ostatní = Bronze
         else 'Bronze'
       end SLA,
       -- servername
       -- pokud je db v clusteru, vrat scanName, jinak server name
       NVL2(cluster_name, scanName, server_name)
         || ':' || port || '/'||
         NVL2(domain, database_name||'.'||domain, database_name)  AS CONNECT_DESCRIPTOR,
       NVL2(cluster_name, scanName, server_name) server_name,
       port,
       d.host_name,
       p.platform,
       db_size_mb,
       db_log_size_mb,
       dg.diskgroup AS ASM_DISKGROUP
  FROM
    MGMT$DB_DBNINSTANCEINFO d
    JOIN MGMT$TARGET_PROPERTIES
      PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
        'orcl_gtp_lifecycle_status' as env_status,
        'RACOption' as rac,
        'ClusterName' as cluster_name,
        'MachineName' as server_name,
        'DBDomain' as domain,
        'Port' as port,
        'orcl_gtp_os' as platform
        )) p ON (d.target_guid = p.target_guid)
  -- pouze DB bez RAC instance
  INNER JOIN MGMT$TARGET t on (d.target_guid = t.target_guid)
  -- availability
  INNER JOIN (
     select target_guid,
            max(availability_status_code) availability_status_code
     from MGMT$AVAILABILITY_CURRENT
      group by target_guid) a on (d.target_guid = a.target_guid)
  -- DB and FRA size
  LEFT JOIN (
    SELECT
        s.target_guid,
        round(s.value*1024) as db_size_mb,
        round(f.value/power(1024,2)) as db_log_size_mb
    FROM
        mgmt$metric_current s
        JOIN mgmt$metric_current f ON (s.target_guid = f.target_guid)
    WHERE s.metric_name     = 'DATABASE_SIZE'
      AND s.metric_column   = 'ALLOCATED_GB'
      AND f.metric_name     = 'ha_flashrecovery'
      AND f.metric_column   = 'flash_recovery_area_size') ds
   ON d.target_guid = ds.target_guid
  -- join scanName dle clusterName
  LEFT JOIN (select target_name, property_value scanName
         from MGMT$TARGET_PROPERTIES
        where property_name = 'scanName') s
    ON p.cluster_name = s.target_name
  -- ASM diskgroup concat s ","
  LEFT JOIN (
      select db_name,
             listagg(diskgroup, ',' ) within group (order by diskgroup) as diskgroup
         from (
            select distinct db_name,  diskgroup
             from MGMT_ASM_CLIENT_ECM)
        group by db_name
        ) dg on (dg.db_name = d.database_name)
WHERE -- t.TYPE_QUALIFIER3 = 'DB'  -- nefunguje kvuli 12.2. verzi db
      t.TARGET_TYPE in ('rac_database', 'oracle_database')
  and TYPE_QUALIFIER3 != 'RACINST'
--  and database_name = 'CPTZ'
;
