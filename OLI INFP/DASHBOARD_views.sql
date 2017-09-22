--
-- INFP
--

-- TEST pro kontrolu parametrů
create user SVOBODA identified by abcd1234 profile prof_dba;
grant dba to SVOBODA;
grant dba to DKRCH;


db linky:
- INFTA - změněno na PUBLIC
CREATE PUBLIC DATABASE LINK "OEM_PROD" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMSP';
CREATE PUBLIC DATABASE LINK "OEM_TEST" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMST';


connect DASHBOARD/abcd1234


-- nové verze view, zatím nenasazeny
-- přehodit na VM ?

-- CPU MEM SIZE per db instance
--
-- jeste si pohrat s SGA a PGA, aby to byly fixné hodnoty
-- nakonec posilam pouze statickou SGA size
CREATE MATERIALIZED VIEW DASHBOARD.EM_INSTANCE
REFRESH FORCE START WITH SYSDATE NEXT trunc(sysdate + 1)
AS
SELECT
    d.target_guid em_guid,
    d.database_name dbname,
    d.instance_name,
    cpu_count cpu,
    m.sgasize sga_size_mb   -- SGA size
FROM
    MGMT$DB_CPU_USAGE c
    JOIN CM$MGMT_DB_SGA_ECM m ON (c.target_guid = m.cm_target_guid)
    JOIN mgmt$db_dbninstanceinfo d ON (m.cm_target_guid = d.target_guid)
WHERE m.sganame = 'Total SGA (MB)'
-- ORDER BY d.database_name
;

COMMENT ON MATERIALIZED VIEW "DASHBOARD"."EM_INSTANCE"  IS
  'Snapshot EM database instance včetně CPU MEM SIZE';

- pridat indexy ?

-- EM_DATABASE
-- - vcetne DSN
CREATE MATERIALIZED VIEW DASHBOARD.EM_DATABASE
REFRESH FORCE START WITH SYSDATE NEXT trunc(sysdate + 1)
AS
select t.target_guid em_guid,
       t.target_name,
       database_name dbname,
       log_mode,
       characterset,
       substr(d.supplemental_log_data_min, 1, 1) SL_MIN,
       dbversion, env_status,
       substr(is_rac, 1,1) is_rac,
       -- SLA
       CASE
         when (is_rac = 'YES' and env_status = 'Production')
              then 'Platinum'
         -- produkce v A/P clusteru
         when (is_rac = 'NO' and env_status = 'Production')
              then 'Gold'
         -- others = Bronze
         else 'Bronze'
       end SLA,
       -- servername
       -- pokud je db v clsteru, vrat scanName, jinak server name
       NVL2(cluster_name, scanName, server_name) server_name,
       port,
       db_size_mb,
       db_log_size_mb
  FROM
    MGMT$DB_DBNINSTANCEINFO d
    JOIN MGMT$TARGET_PROPERTIES
      PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
        'orcl_gtp_lifecycle_status' as env_status,
        'RACOption' as is_rac,
        'ClusterName' as cluster_name,
        'MachineName' as server_name,
        'Port' as port
        )) p ON (d.target_guid = p.target_guid)
  -- pouze DB bez RAC instance
  JOIN MGMT$TARGET t on (d.target_guid = t.target_guid)
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
  -- pouze DB bez RAC instance
WHERE t.TYPE_QUALIFIER3 = 'DB'
--ORDER BY dbname
;

-- OLI data pro REST
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."OLI_DATABASE"
AS
SELECT d.EM_GUID DB_EM_GUID,
       i.EM_GUID INST_EM_GUID,
       dbname,
       inst_name instance_name,
       app_name,
       NVL2(domain, hostname||'.'||domain, hostname) server_name,
       env_status
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
-- WHERE 1=1
--   and domain = ''
        -- AND dbname like 'DWHTA%'
-- ORDER BY dbname, inst_name
;

--
-- MGMT CM view protažené z EM do OLI dashboard
--

connect DASHBOARD/abcd1234

CREATE OR REPLACE FORCE VIEW MGMT$METRIC_CURRENT AS
select  * from MGMT$METRIC_CURRENT@oem_prod
;


CREATE OR REPLACE FORCE VIEW "MGMT$DB_INIT_PARAMS" AS
select * from MGMT$DB_INIT_PARAMS@oem_prod
;

CREATE OR REPLACE FORCE VIEW "MGMT$DB_DBNINSTANCEINFO"  AS
  select  *
from MGMT$DB_DBNINSTANCEINFO@oem_prod
;

CREATE OR REPLACE FORCE VIEW "CM$MGMT_ASM_CLIENT_ECM" AS
SELECT * FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
;

CREATE OR REPLACE FORCE VIEW "CM$MGMT_DB_SGA_ECM" AS
SELECT * FROM CM$MGMT_DB_SGA_ECM@oem_prod
;

CREATE OR REPLACE FORCE VIEW MGMT_ASM_DISKGROUP_ECM AS
SELECT * FROM SYSMAN.MGMT_ASM_DISKGROUP_ECM@oem_prod
/

CREATE OR REPLACE FORCE VIEW "MGMT$DB_SGA" AS
SELECT * FROM MGMT$DB_SGA@OEM_PROD
;
