--
-- INFP
--

koncepce:
- rac = Y/N
- is_rac = true/false pro JSON


--
-- CHECK
--

-- SELECT
define db = BRATA
select em_guid, dbname, env_status FROM EM_DATABASE where dbname = '&db';
select dbname, env_status FROM OLI_DATABASE  where dbname = '&db';
select * from API_DB_MV where dbname = '&db';
select * from MGMT$DB_DBNINSTANCEINFO where target_name like '&db';


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

ALTER USER DASHBOARD ENABLE EDITIONS;

grant MGMT_USER to DASHBOARD;
grant EXEMPT ACCESS POLICY to DASHBOARD;

INSERT INTO SYSMAN.mgmt_role_grants VALUES ('DASHBOARD','EM_USER',0 , 0);
INSERT INTO SYSMAN.mgmt_role_grants VALUES ('DASHBOARD','EM_ALL_VIEWER',0 , 0);
COMMIT;

sqlplus /nolog
connect DASHBOARD/abcd1234


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

- je to vcetne DBMS_SNAPSHOT.REFRESH('DASHBOARD.API_DB_MV','C');

-- pridat do ansible ?
exec DBMS_SNAPSHOT.REFRESH('DASHBOARD.API_DB_MV','C');

-- refresh ALL views - není potřeba
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

-- namísto VIEW dávat TABLE, pak funguje comment
COMMENT ON TABLE "DASHBOARD"."EM_INSTANCE" IS
  'OEM data pro target db instance včetně CPU MEM SIZE';

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_DATABASE"
AS
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
/

-- OLI data pro REST
-- APP NAME listagg by ","
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."OLI_DATABASE"
AS
SELECT d.licdb_id,
       d.EM_GUID DB_EM_GUID,
       d.ca_id db_cmdb_ca_id,
       dbname,
       rac,
       env_status,
       LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY APP_NAME) app_name
 FROM
       OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
 group by d.licdb_id,
       d.EM_GUID,
       d.ca_id,
       dbname,
       rac,
       env_status
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
       e.rac is_rac,
       e.log_mode is_archivelog,
       o.app_name,
       e.env_status,
       e.availability,
       e.host_name,
       e.platform,
       e.server_name, e.port, e.connect_descriptor,
       round(e.db_size_mb / 1024) as db_size_gb,
       e.asm_diskgroup
FROM
             OLI_DATABASE o
  inner join EM_DATABASE e
     on  (e.dbname = o.dbname and e.env_status = o.env_status)
;

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."API_DB"
  AS
SELECT * from DASHBOARD.API_DB_MV
;


--
-- server
--

select hostname, os, envstatus as env
  from em_hosts_v
;

--
-- MGMT EM / CM view protažené přes MView z EM do OLI dashboard
--

sqlplus dashboard/abcd1234

-- pridat refresh mview do procky pro refresh
CREATE OR REPLACE FORCE VIEW dashboard.MGMT_TARGETS
AS
  select * from SYSMAN.MGMT_TARGETS@OEM_PROD
    UNION
  select * from SYSMAN.MGMT_TARGETS@OEM_TEST
;

CREATE OR REPLACE FORCE VIEW dashboard.MGMT$AVAILABILITY_CURRENT
AS
  select * from SYSMAN.MGMT$AVAILABILITY_CURRENT@OEM_PROD
    UNION
  select * from SYSMAN.MGMT$AVAILABILITY_CURRENT@OEM_TEST
;

..

-- přegenerovat view, kde není UNION na UNION test a prod
set pages 0
select 'CREATE OR REPLACE FORCE VIEW '||owner||'.'||view_name||chr(10)||
   '  AS '||chr(10)||
   'SELECT  * FROM SYSMAN.' ||view_name|| '@OEM_PROD'||chr(10)||
   '  UNION '||chr(10)||
   'SELECT  * FROM SYSMAN.' ||view_name|| '@OEM_TEST'||chr(10)||
   '/'||chr(10) as cmd
from dba_views
  where owner = 'DASHBOARD'
    and view_name like '%MGMT%'
    and TEXT_VC not like '%UNION%'
    -- vyjimky mezi verzi OEM 12c a 13c
    -- and view_name not in ('MGMT_TARGETS')
;


..


-- tyto view nejdou vytáhnout z OEM
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

set lines 32767 pages 0
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

GRANT SELECT on DASHBOARD.MGMT$TARGET_PROPERTIES to REDIM_OWNER WITH GRANT OPTION;
..

GRANT SELECT on SYSMAN.MGMT_ASM_CLIENT_ECM to DASHBOARD WITH GRANT OPTION;
"ORA-38818: neplatný odkaz na upravovaný objekt SYSMAN.MGMT_ASM_CLIENT_ECM
"

-- OMSP OMST zkracena verze EM_DATABASE
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DASHBOARD"."EM_DATABASE"
  AS
  select
       database_name dbname,
       -- availability short na UP a DOWN
       decode(a.availability_status_code, 0, 'DOWN', 1, 'UP', 'UNKNOWN') availability,
       dbversion,
       env_status,
       decode(substr(rac, 1, 1), 'Y', 'true', 'false') rac,
       NVL2(cluster_name, scanName, server_name)
         || ':' || port || '/'||
         NVL2(domain, database_name||'.'||domain, database_name)  AS CONNECT_DESCRIPTOR
  FROM
    SYSMAN.MGMT$DB_DBNINSTANCEINFO d
    JOIN SYSMAN.MGMT$TARGET_PROPERTIES
      PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
        'orcl_gtp_lifecycle_status' as env_status,
        'RACOption' as rac,
        'ClusterName' as cluster_name,
        'MachineName' as server_name,
        'DBDomain' as domain,
        'Port' as port
        )) p ON (d.target_guid = p.target_guid)
  -- pouze DB bez RAC instance
  INNER JOIN SYSMAN.MGMT$TARGET t on (d.target_guid = t.target_guid)
  -- availability
  INNER JOIN (
     select target_guid,
            max(availability_status_code) availability_status_code
     from SYSMAN.MGMT$AVAILABILITY_CURRENT
      group by target_guid) a on (d.target_guid = a.target_guid)
  LEFT JOIN (select target_name, property_value scanName
         from SYSMAN.MGMT$TARGET_PROPERTIES
        where property_name = 'scanName') s
    ON p.cluster_name = s.target_name
WHERE --t.TYPE_QUALIFIER3 = 'DB'  -- nefunguje kvuli 12.2. verzi db
        t.TARGET_TYPE in ('rac_database', 'oracle_database')
    and TYPE_QUALIFIER3 != 'RACINST'
    --and database_name = 'BOSON'
;
