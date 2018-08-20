
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
CREATE DATABASE LINK "OEM_PROD" CONNECT TO DASHBOARD IDENTIFIED BY abcd1234 USING 'OMSP';
CREATE DATABASE LINK "OEM_TEST" CONNECT TO DASHBOARD IDENTIFIED BY abcd1234 USING 'OMST';

--
create user DASHBOARD identified by abcd1234 profile DEFAULT;
  grant SELECT ANY TABLE, UNLIMITED TABLESPACE  to DASHBOARD;

INSERT INTO SYSMAN.mgmt_role_grants VALUES ('DASHBOARD','EM_ALL_VIEWER',0,0);
COMMIT;

connect DASHBOARD/abcd1234

-- test DWHPOC3
select * from MGMT$DB_DBNINSTANCEINFO
where target_name like 'DWHPOC3%'
;

-- Sync JOB

exec dbms_scheduler.run_job('DASHBOARD.OMS_OLI_REFRESH_DATA', use_current_session => TRUE);

'DASHBOARD.OMS_OLI_REFRESH_DATA'
    - oracle_sql:
        service_name: "{{ infp.service_name }}"
        sql: |
          call dbms_scheduler.run_job('DASHBOARD.OMS_OLI_REFRESH_DATA', use_current_session => TRUE)
      environment: "{{ infp_env }}"
      register: sql_result

JOB ACTION:
"DASHBOARD"."REFRESH_OLI_DBHOST_PROPERTIES"

-- pridat do ansible ?
exec DBMS_SNAPSHOT.REFRESH('DASHBOARD.API_DB_MV','C');

-- refresh ALL
DECLARE
  v_number_of_failures NUMBER(12) := 0;
BEGIN
  DBMS_MVIEW.REFRESH_ALL_MVIEWS(v_number_of_failures,'C','', TRUE, FALSE);
END;
/


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

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DASHBOARD"."EM_DATABASE" ("EM_GUID", "TARGET_NAME", "DBNAME", "LOG_MODE", "CHARACTERSET", "SL_MIN", "DBVERSION", "ENV_STATUS", "RAC", "SLA", "CONNECT_DESCRIPTOR", "SERVER_NAME", "PORT", "HOST_NAME", "DB_SIZE_MB", "DB_LOG_SIZE_MB", "ASM_DISKGROUP") AS
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
  --and database_name = 'CPTZ'
;

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
       round(e.db_size_mb / 1024) as db_size_gb,
       e.ASM_DISKGROUP
FROM
  OLI_DATABASE o
  join EM_DATABASE e on o.DB_EM_GUID = e.em_guid
;


CREATE OR REPLACE FORCE VIEW "DASHBOARD"."API_DB"
  AS
SELECT * from DASHBOARD.API_DB_MV
;
--  where dbname not in (


--
'CATEST1', 'CATEST2', 'PWTESTA', 'TECOM1', 'TGASPER2', 'TPTESTA', 'TPTESTB'


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
CREATE OR REPLACE FORCE VIEW MGMT_TARGETS
AS
 select * from SYSMAN.MGMT_TARGETS@OEM_PROD
 union
 select target_name, target_type, type_meta_ver, category_prop_1, category_prop_2, category_prop_3, category_prop_4, category_prop_5, target_guid, load_timestamp, timezone_delta, timezone_region, display_name, owner, type_display_name, service_type, host_name, emd_url, last_load_time, is_group, broken_reason, broken_str, last_rt_load_time, last_updated_time, monitoring_mode, rep_side_avail, last_e2e_load_time, is_propagating, discovered_name, manage_status, is_active, promote_status, dynamic_property_status, org_id, oracle_home, oracle_config_home, unique_id, is_ready, is_ready_for_job, is_cloud_service
 from SYSMAN.MGMT_TARGETS@OEM_TEST;

CREATE OR REPLACE FORCE VIEW MGMT$TARGET
AS
 select  * from MGMT$TARGET@OEM_PROD
 union
  select * from SYSMAN.MGMT$TARGET@OEM_TEST;

CREATE OR REPLACE FORCE VIEW MGMT$TARGET_PROPERTIES AS
select  * from SYSMAN.MGMT$TARGET_PROPERTIES@OEM_PROD
union
select  * from SYSMAN.MGMT$TARGET_PROPERTIES@OEM_TEST;



CREATE OR REPLACE FORCE VIEW MGMT_ASM_CLIENT_ECM AS
select * from SYSMAN.MGMT_ASM_CLIENT_ECM@OEM_PROD
union
select * from SYSMAN.MGMT_ASM_CLIENT_ECM@OEM_TEST;


CREATE OR REPLACE FORCE VIEW MGMT$DB_CPU_USAGE
AS
select  * from SYSMAN.MGMT$DB_CPU_USAGE@OEM_PROD
union
select  * from SYSMAN.MGMT$DB_CPU_USAGE@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW mgmt$db_users
AS
select  * from SYSMAN.mgmt$db_users@OEM_PROD
union
select  * from SYSMAN.mgmt$db_users@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW MGMT$DB_DBNINSTANCEINFO
AS
select  * from SYSMAN.MGMT$DB_DBNINSTANCEINFO@OEM_PROD
union
select  * from SYSMAN.MGMT$DB_DBNINSTANCEINFO@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW MGMT$METRIC_CURRENT
AS
select  * from SYSMAN.MGMT$METRIC_CURRENT@oem_prod
union
select  * from SYSMAN.MGMT$METRIC_CURRENT@oem_test
;



CREATE OR REPLACE FORCE VIEW "CM$MGMT_ASM_CLIENT_ECM"
AS
SELECT * FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
union
SELECT * FROM SYSMAN.CM$MGMT_ASM_CLIENT_ECM@oem_test
;


CREATE OR REPLACE FORCE VIEW "CM$MGMT_DB_SGA_ECM"
AS
SELECT * FROM SYSMAN.CM$MGMT_DB_SGA_ECM@oem_prod
union
SELECT * FROM SYSMAN.CM$MGMT_DB_SGA_ECM@oem_test
;


CREATE OR REPLACE FORCE VIEW MGMT_ASM_DISKGROUP_ECM
AS
SELECT * FROM SYSMAN.MGMT_ASM_DISKGROUP_ECM@oem_prod
union
SELECT * FROM SYSMAN.MGMT_ASM_DISKGROUP_ECM@oem_test
/

CREATE OR REPLACE FORCE VIEW "MGMT$DB_SGA" AS SELECT * FROM MGMT$DB_SGA@OEM_PROD;


-- nevyužité ?
CREATE OR REPLACE FORCE VIEW MGMT$TARGET_FLAT_MEMBERS
AS
select  * from SYSMAN.MGMT$TARGET_FLAT_MEMBERS@OEM_PROD
union
SELECT * FROM SYSMAN.MGMT$TARGET_FLAT_MEMBERS@oem_test
;


CREATE OR REPLACE FORCE VIEW MGMT$TARGET_ASSOCIATIONS
AS
select  * from MGMT$TARGET_ASSOCIATIONS@OEM_PROD
union
SELECT * FROM SYSMAN.MGMT$TARGET_ASSOCIATIONS@oem_test
;


CREATE OR REPLACE FORCE VIEW mgmt$target_type
AS select  * from mgmt$target_type@OEM_PROD
union
SELECT * FROM SYSMAN.mgmt$target_type@oem_test
;

CREATE OR REPLACE FORCE VIEW mgmt$os_hw_summary
AS select  * from mgmt$os_hw_summary@OEM_PROD
union
SELECT * FROM SYSMAN.mgmt$os_hw_summary@oem_test
;

CREATE OR REPLACE FORCE VIEW mgmt$metric_daily
AS select  * from mgmt$metric_daily@OEM_PROD
union
SELECT * FROM SYSMAN.mgmt$metric_daily@oem_test
;

CREATE OR REPLACE FORCE VIEW mgmt$METRIC_HOURLY
AS select  * from mgmt$METRIC_HOURLY@OEM_PROD
union
SELECT * FROM SYSMAN.mgmt$METRIC_HOURLY@oem_test
;

-- OLI
CREATE OR REPLACE FORCE VIEW MGMT$DB_OPTIONS
AS select  * from SYSMAN.MGMT$DB_OPTIONS@OEM_PROD
union
SELECT * FROM SYSMAN.MGMT$DB_OPTIONS@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW "MGMT$DB_INIT_PARAMS"
AS
select * from MGMT$DB_INIT_PARAMS@oem_prod
union
select * from SYSMAN.MGMT$DB_INIT_PARAMS@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW MGMT$DB_FEATUREUSAGE AS
select * from MGMT$DB_FEATUREUSAGE@OEM_PROD
union
select * from SYSMAN.MGMT$DB_FEATUREUSAGE@OEM_TEST
;


-- GC view ORA-22804: remote operations not permitted
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
set lines 32767 pages 0
select 'GRANT '||privilege||
      ' on '||owner||'.'||table_name||
      ' to OLI_OWNER, CLONING_OWNER, REDIM_OWNER, UMO_USER' ||
      ';' as CMD
  from dba_tab_privs
 where owner = 'DASHBOARD'
 order by grantee, privilege
;

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
GRANT SELECT on DASHBOARD.mgmt$db_users to REDIM_OWNER WITH GRANT OPTION;
GRANT SELECT on DASHBOARD.mgmt$db_dbninstanceinfo to REDIM_OWNER WITH GRANT OPTION;
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

GRANT SELECT on DASHBOARD.MGMT$DB_OPTIONS to OLI_OWNER;
GRANT SELECT on DASHBOARD.MGMT$DB_INIT_PARAMS to OLI_OWNER;
GRANT SELECT on DASHBOARD.MGMT$DB_FEATUREUSAGE to OLI_OWNER;
GRANT SELECT on DASHBOARD.MGMT$DB_DBNINSTANCEINFO to OLI_OWNER;