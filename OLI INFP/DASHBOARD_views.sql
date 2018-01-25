
--
-- INFP
--

- koncepce:
- rac = Y/N
- is_rac = true/false pro JSON

-- TEST pro kontrolu parametrů
create user SVOBODA identified by abcd1234 profile prof_dba;
grant dba to SVOBODA;
grant dba to DKRCH;

create user PATOCKA identified by abcd1234 profile prof_dba;
grant CSCONNECT, select any table to PATOCKA:


db linky:
- INFTA - změněno na PUBLIC
CREATE PUBLIC DATABASE LINK "OEM_PROD" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMSP';
CREATE PUBLIC DATABASE LINK "OEM_TEST" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMST';

-- private db linky
DROP DATABASE LINK "OEM_PROD";
CREATE DATABASE LINK "OEM_PROD" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMSP';

--
create user DASHBOARD identified by abcd1234 profile DEFAULT;
grant CONNECT, CS_DBMGMT_ACCOUNTS, MGMT_USER, DBA to DASHBOARD;
grant SELECT ANY TABLE, UNLIMITED TABLESPACE  to DASHBOARD;

INSERT INTO SYSMAN.mgmt_role_grants VALUES ('DASHBOARD','EM_ALL_VIEWER',0,0);
COMMIT;

connect DASHBOARD/abcd1234


-- nové verze view, zatím nenasazeny
-- přehodit na VM ?

-- CPU MEM SIZE per db instance
--
-- jeste si pohrat s SGA a PGA, aby to byly fixné hodnoty
-- nakonec posilam pouze statickou SGA size

-- pokud používám MView namísto view
CREATE OR REPLACE FORCE VIEW DASHBOARD.EM_INSTANCE
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

COMMENT ON VIEW "DASHBOARD"."EM_INSTANCE"  IS
  'OEM data pro target db instance včetně CPU MEM SIZE';

- pridat indexy ?

-- EM_DATABASE
--   - connect stringu
--   - db size in MB
--   - fra size in MB
CREATE OR REPLACE FORCE VIEW DASHBOARD.EM_DATABASE
AS
select t.target_guid em_guid,
       t.target_name,
       database_name dbname,
       log_mode,
       characterset,
       substr(d.supplemental_log_data_min, 1, 1) SL_MIN,
       dbversion, env_status,
       substr(rac, 1,1) rac,
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
       -- pokud je db v clsteru, vrat scanName, jinak server name
       NVL2(cluster_name, scanName, server_name)
         || ':' || port || '/'||
         NVL2(domain, database_name||'.'||domain, database_name)  AS CONNECT_DESCRIPTOR,
       NVL2(cluster_name, scanName, server_name) server_name,
       port,
       d.host_name,
       db_size_mb,
       db_log_size_mb
  FROM
    MGMT$DB_DBNINSTANCEINFO d
    JOIN MGMT$TARGET_PROPERTIES
      PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
        'orcl_gtp_lifecycle_status' as env_status,
        'RACOption' as rac,
        'ClusterName' as cluster_name,
        'MachineName' as server_name,
        'DBDomain' as domain,
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
  -- and database_name = 'CPTZ'
/


--
-- COMMENT ON VIEW "DASHBOARD"."EM_DATABASE"  IS
--  'OEM data pro target databaze vcetne db size, fra size';


-- OLI data pro REST
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."OLI_DATABASE"
AS
SELECT d.licdb_id,
       d.EM_GUID DB_EM_GUID,
       d.ca_id db_cmdb_ca_id,
       dbname,
       rac,
       app_name,
       env_status
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
/

-- OLI data db instance pro REST
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."OLI_INSTANCE"
AS
SELECT d.EM_GUID DB_EM_GUID,
       i.EM_GUID INST_EM_GUID,
       i.ca_id dbinst_cmdb_ci_id,
       dbname,
       inst_name instance_name,
       app_name,
       NVL2(domain, hostname||'.'||domain, hostname) server_name,
       le.farm,
       le.lic_env_name,
       env_status
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.server_id = s.server_id)
  JOIN OLI_OWNER.LICENSED_ENVIRONMENTS le ON (le.lic_env_id = s.lic_env_id)
-- WHERE 1=1
--   and domain = ''
        -- AND dbname like 'DWHTA%'
-- ORDER BY dbname, inst_name
/

-- API_DB
DROP MATERIALIZED VIEW DASHBOARD.API_DB_MV;
CREATE MATERIALIZED VIEW DASHBOARD.API_DB_MV
NOLOGGING
REFRESH COMPLETE
START WITH (SYSDATE) NEXT SYSDATE + 6/24
WITH PRIMARY KEY
  AS
  SELECT
       e.dbname,
       e.dbversion,
       decode(e.rac, 'Y', 'true', 'false') is_rac,
       decode(e.log_mode, 'ARCHIVELOG', 'true', 'false') is_archivelog,
       o.app_name,
       e.env_status,
       e.host_name,
       e.server_name, e.port, e.connect_descriptor,
       round(e.db_size_mb / 1024) as db_size_gb
FROM
  OLI_DATABASE o
  join EM_DATABASE e on o.DB_EM_GUID = e.em_guid
;

-- pridat do ansible ?
exec DBMS_SNAPSHOT.REFRESH('DASHBOARD.API_DB_MV','C');

-- refresh ALL
DECLARE
  v_number_of_failures NUMBER(12) := 0;
BEGIN
  DBMS_MVIEW.REFRESH_ALL_MVIEWS(v_number_of_failures,'C','', TRUE, FALSE);
END;
/

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."API_DB"
  AS
SELECT * from DASHBOARD.API_DB_MV
;
--  where dbname not in (


--
'CATEST1', 'CATEST2', 'PWTESTA', 'TECOM1', 'TGASPER2', 'TPTESTA', 'TPTESTB'

-- zprovoznit
SDJB
SDJO
SDST
SK1O



-- puvodni varianta s VIEW
  SELECT /*+ result_cache */
       e.dbname,
       e.dbversion,
       decode(e.rac, 'Y', 'true', 'false') is_rac,
       decode(e.log_mode, 'ARCHIVELOG', 'true', 'false') is_archivelog,
       o.app_name,
       e.env_status,
       e.host_name,
       e.server_name, e.port, e.connect_descriptor,
       round(e.db_size_mb / 1024) as db_size_gb
FROM
  OLI_DATABASE o
  join EM_DATABASE e on o.DB_EM_GUID = e.em_guid;


--
-- MGMT EM / CM view protažené přes MView z EM do OLI dashboard
--

connect DASHBOARD/abcd1234

-- pridat refresh mview do procky pro refresh
CREATE OR REPLACE FORCE VIEW MGMT_TARGETS AS select  * from MGMT_TARGETS@OEM_PROD;

CREATE OR REPLACE FORCE VIEW MGMT$TARGET AS select  * from MGMT$TARGET@OEM_PROD;

CREATE OR REPLACE FORCE VIEW MGMT$TARGET_PROPERTIES AS select  * from MGMT$TARGET_PROPERTIES@OEM_PROD;

drop view MGMT$TARGET_FLAT_MEMBERS;
CREATE OR REPLACE FORCE VIEW MGMT$TARGET_FLAT_MEMBERS
AS select  * from MGMT$TARGET_FLAT_MEMBERS@OEM_PROD
;

drop view MGMT$TARGET_ASSOCIATIONS;
CREATE OR REPLACE FORCE VIEW MGMT$TARGET_ASSOCIATIONS
AS select  * from MGMT$TARGET_ASSOCIATIONS@OEM_PROD
;

drop view mgmt$target_type;
CREATE OR REPLACE FORCE VIEW mgmt$target_type
AS select  * from mgmt$target_type@OEM_PROD
;

drop view mgmt$os_hw_summary;
CREATE OR REPLACE FORCE VIEW mgmt$os_hw_summary
AS select  * from mgmt$os_hw_summary@OEM_PROD
;

drop view mgmt$metric_daily;
CREATE OR REPLACE FORCE VIEW mgmt$metric_daily
AS select  * from mgmt$metric_daily@OEM_PROD
;

drop view mgmt$METRIC_HOURLY;
CREATE OR REPLACE FORCE VIEW mgmt$METRIC_HOURLY
AS select  * from mgmt$METRIC_HOURLY@OEM_PROD
;

drop view MGMT$DB_CPU_USAGE;
CREATE OR REPLACE FORCE VIEW MGMT$DB_CPU_USAGE
AS select  * from MGMT$DB_CPU_USAGE@OEM_PROD
;



DROP VIEW MGMT$DB_DBNINSTANCEINFO ;
CREATE OR REPLACE FORCE VIEW "MGMT$DB_DBNINSTANCEINFO"
AS select  * from MGMT$DB_DBNINSTANCEINFO@oem_prod
;

DROP VIEW MGMT$METRIC_CURRENT ;
CREATE OR REPLACE FORCE VIEW MGMT$METRIC_CURRENT
AS
select  * from MGMT$METRIC_CURRENT@oem_prod
;

DROP VIEW MGMT$DB_INIT_PARAMS ;
CREATE OR REPLACE FORCE VIEW "MGMT$DB_INIT_PARAMS"
AS
select * from MGMT$DB_INIT_PARAMS@oem_prod
;

DROP VIEW CM$MGMT_ASM_CLIENT_ECM ;
CREATE OR REPLACE FORCE VIEW "CM$MGMT_ASM_CLIENT_ECM"
AS
SELECT * FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
;


DROP VIEW CM$MGMT_DB_SGA_ECM ;
CREATE OR REPLACE FORCE VIEW "CM$MGMT_DB_SGA_ECM"
AS
SELECT * FROM CM$MGMT_DB_SGA_ECM@oem_prod
;

DROP VIEW MGMT_ASM_DISKGROUP_ECM ;
CREATE OR REPLACE FORCE VIEW MGMT_ASM_DISKGROUP_ECM
AS
SELECT * FROM SYSMAN.MGMT_ASM_DISKGROUP_ECM@oem_prod
/

CREATE OR REPLACE FORCE VIEW "MGMT$DB_SGA" AS SELECT * FROM MGMT$DB_SGA@OEM_PROD;

-- GC view
CREATE OR REPLACE FORCE VIEW "GC_TARGET_IDENTIFIERS" AS SELECT * FROM SYSMAN.GC_TARGET_IDENTIFIERS@OEM_PROD;

--> nelze
ORA-22804: remote operations not permitted on object tables or user-defined type columns
22804. 00000 -  "remote operations not permitted on object tables or user-defined type columns"
*Cause:    An attempt was made to perform queries or DML operations on
           remote object
           tables or on remote table columns whose type is one of object,
           REF, nested table or VARRAY.


--
-- OLI REFRESH
--

PROCEDURE           refresh_oli_dbhost_properties


-- dashboard grants - verze: 20170925
select 'GRANT '||privilege||
      ' on '||owner||'.'||table_name||
      ' to '||grantee||
        decode(grantable,'YES',' WITH GRANT OPTION')||';' CMD
  from dba_tab_privs
 where owner = 'DASHBOARD'
 order by grantee, privilege
;

GRANT SELECT on DASHBOARD.MGMT$DB_INIT_PARAMS to CLONING_OWNER;
GRANT SELECT on DASHBOARD.MGMT$DB_DBNINSTANCEINFO to CLONING_OWNER;
GRANT SELECT on DASHBOARD.CM$MGMT_ASM_CLIENT_ECM to CLONING_OWNER;
GRANT EXECUTE on DASHBOARD.REFRESH_OLI_DBHOST_PROPERTIES to OLI_OWNER;
GRANT SELECT on DASHBOARD.MGMT$DB_DBNINSTANCEINFO to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$TARGET_PROPERTIES to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$TARGET to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$METRIC_CURRENT to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$METRIC_HOURLY to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.EM_DATABASES_V to OLI_OWNER;
GRANT SELECT on DASHBOARD.EM_DBINSTANCES_V to OLI_OWNER;
GRANT SELECT on DASHBOARD.EM_HOSTS_V to OLI_OWNER;
GRANT SELECT on DASHBOARD.CM$MGMT_DB_SGA_ECM to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.EM_DATABASE to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.EM_INSTANCE to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.EM_INSTANCE_CPU_MEM_SIZE to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.EM_DATABASE_INFO to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$DB_INIT_PARAMS to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.DBHOST_PROPERTIES to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.DBHOST_PROPERTIES_V to OLI_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.DBHOST_PROPERTIES_V to OLI_SUPP WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.DBHOST_PROPERTIES to OLI_SUPP WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.ALL_MGMT_TARGETS to REDIM_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$TARGET to REDIM_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$TARGET_PROPERTIES to REDIM_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.MGMT$TARGET_PROPERTIES to REDIM_ROLE;
GRANT SELECT on DASHBOARD.ALL_MGMT_TARGETS to REDIM_ROLE;
GRANT SELECT on DASHBOARD.MGMT$TARGET to REDIM_ROLE;
GRANT SELECT on DASHBOARD.EM_METRIC_ITEMS to UMO_USER;
GRANT SELECT on DASHBOARD.EM_METRIC_KEYS to UMO_USER;
GRANT SELECT on DASHBOARD.EM_METRIC_GROUPS to UMO_USER;
GRANT SELECT on DASHBOARD.EM_METRIC_COLUMNS to UMO_USER;
GRANT SELECT on DASHBOARD.MGMT_TARGETS to UMO_USER;
GRANT SELECT on DASHBOARD.MGMT_TARGET_ASSOC_DEFS to UMO_USER;
GRANT SELECT on DASHBOARD.MGMT_TARGET_PROPERTIES to UMO_USER;
GRANT SELECT on DASHBOARD.MGMT_TARGET_ASSOCS to UMO_USER;
GRANT SELECT on DASHBOARD.ALL_MGMT_TARGETS to UMO_USER;
GRANT SELECT on DASHBOARD.ALL_MGMT_TARGETS_LOAD_TIMES to UMO_USER;
GRANT SELECT on DASHBOARD.ALL_OLD_MGMT_TARGET to UMO_USER;
