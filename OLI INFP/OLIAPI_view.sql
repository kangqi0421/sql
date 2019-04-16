--
-- OLIAPI CA CMDB view
--

-- TODO: založit ownera OLI_API ? -> zneužijeme účet DASHBOARD
--

grant execute on job

call dbms_scheduler.run_job('DASHBOARD.OMS_OLI_REFRESH_DATA', use_current_session => TRUE)

grant select, insert, update, delete nad OLI tabulkami ?


GRANT EXECUTE ON OLI_OWNER.OLI_API TO  DASHBOARD;
CREATE OR REPLACE SYNONYM DASHBOARD.OLI_API for OLI_OWNER.OLI_API;

connect dashboard/abcd1234

-- add server
set serveroutput on
DECLARE
   server_id PLS_INTEGER;
BEGIN
   server_id := OLI_OWNER.OLI_API.ADD_SERVER('dpdetdb01.vs.csin.cz');
   dbms_output.put_line('server_id: ' || server_id);
END;
/
commit;

-- add db
set serveroutput on
DECLARE
   licdb_id INTEGER;
BEGIN
   licdb_id := OLI_API.add_database('DWHPOC', 'DWH');
   dbms_output.put_line('licdb_id: ' || licdb_id);
END;
/
commit;


call oli_owner.OLI_API.delete_database('DWH_DUMMY_DDR1');

select 'call OLI_API.delete_database('|| DBMS_ASSERT.enquote_literal(d.dbname) ||');' as cmd
  from OLI_OWNER.DATABASES d
 where d.dbname like 'TS2%';

call OLI_API.delete_database('TS2O');

--
-- delete server - vlastní procedura api_delete_server
--
tbsb2o.vs.csin.cz
call oli_owner.api_delete_server('tbsb2o.vs.csin.cz');
call oli_owner.api_delete_server('tbsb2i.vs.csin.cz');


-- ERROR
delete from databases where licdb_id = 91
Error report -
ORA-02292: integrity constraint (OLI_OWNER.DB_APP_DATABASES_FK) violated - child record found


-- OLAP views

select * from all_views
where view_name like 'OLAPI%';

-- RECOhub
-- základní data do CMDB
connect OLI_RECO_SYNUSR/abcd1234abcd1234
select count(*) from OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG;
select count(*) from  OLI_OWNER.OLIAPI_ORACLE_CMDB_CI;
select count(*) from  OLI_OWNER.OLIAPI_POSTGRES_CMDB_CI;

--
-- SyncOLI
--
--  - přístup přes roli OLI_CA_INTERFACE
--
SyncOLI používá 3 pohledy:
OLAPI_APPS_DB_SERVERS_FARM_FLG
OLAPI_ACQUIRED_LICENSES
OLAPI_LICENCE_USAGE_DETAIL

users:
- OLI_QG0_SYNUSR
- OLI_CA_SYNUSR

-- Sync JOBs
OLI_OWNER.SYNCHRO_CA.RELOAD_ALL > OLI_OWNER.SYNCHRO_CA.RELOAD_ALL

-- Oracle Gateway
/etc/odbc.ini

[casd]
Driver=ODBC Driver 13 for SQL Server
Description=CA Servicedesk database
Trace=No
Server=cadb.csint.cz,5441
Database=mdb

-- CA CMDB casdgw DB link
isql casd zAPI_Oracle_licence Heslo123.

select count(*) from dbo.zAPI_Oracle_licence_apps;


--
-- CA servers
--
ca_servers
ca_relation - VMWare clustery

select hostname, virt_platform_display_name
  from ca_servers
 WHERE hostname in ('todwsrc1', 'tbneldb01');


-- CMDB
CMDB generuje synchronizační log (ve kterém jsou vidět chyby)
http://caservicedesk/reportextracts/SyncLogs/SyncOLI_END.csv

na stejném místě je také konsolidovaný opis datového zdroje
http://caservicedesk/reportextracts/SyncLogs/SyncOLI_APPS_DB_SRVS_FARM_FLG.csv


-- Alešova původní view
select * from OLI_OWNER.OLAPI_ACQUIRED_LICENSES;
select * from OLI_OWNER.OLAPI_LICENCE_USAGE_DETAIL;


-- kontroly:

select * from OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG
  -- mimo kartak
  WHERE domain not like 'ack-prg%'
order by inst_name;

select
    inst_name, dbname,
    db_size_mb, db_log_size_mb , mem_alloc_size_mb
  from OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG
  -- mimo kartak
  WHERE domain not like 'ack-prg%'
  and db_size_mb is NULL
  and mem_alloc_size_mb is NULL
order by inst_name;


-- ostatné view
select * from OLI_OWNER.OLAPI_DATABASES;
select * from OLI_OWNER.OLAPI_DBINSTANCES;
select * from OLI_OWNER.OLAPI_SERVERS;

select * from OLI_OWNER.OLAPI_APPLICATIONS;
select * from OLI_OWNER.OLAPI_APP_DB;
select * from OLI_OWNER.OLAPI_LICENSED_ENVIRONMENTS;


-- granty na OLI_CA_INTERFACE /OLI_QG0_INTERFACE
GRANT SELECT ON OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG TO  OLI_CA_INTERFACE;

-- postgres tables
grant select on postgres.database to OLI_OWNER with GRANT option;
grant select on postgres.PG_DATABASE_NEW to OLI_OWNER with GRANT option;

--
GRANT SELECT ON OLI_OWNER.OLAPI_DATABASES TO  OLI_CA_INTERFACE;
GRANT SELECT ON OLI_OWNER.OLAPI_DATABASES TO  OLI_QG0_INTERFACE;

-- granty na DASHBOARD view WITH GRANT option
GRANT SELECT ON DASHBOARD.MGMT$DB_DBNINSTANCEINFO TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$TARGET_PROPERTIES TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$TARGET TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$METRIC_CURRENT TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$METRIC_HOURLY TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$DB_INIT_PARAMS TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.CM$MGMT_DB_SGA_ECM TO OLI_OWNER with GRANT option;

GRANT SELECT ON DASHBOARD.EM_DATABASE TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.EM_INSTANCE TO OLI_OWNER with GRANT option;

-- grant na OLIAPI view to OLI_CA_INTERFACE - role pro pristup z CA, RecoHUB atd.
BEGIN
for rec in (
    select owner, view_name from all_views
        where owner = 'OLI_OWNER'
      and view_name like '%API%')
  LOOP
    execute immediate 'GRANT SELECT ON '
      || rec.owner ||'.'||rec.view_name
      || ' TO OLI_CA_INTERFACE';
  END LOOP;
END;
/


-- definice OLAPI2_APPS_DB_SRVS_FARM_FLG;
-- nahradit za OLAPI_APPS_DB_SERVERS_FARM_FLG
--
-- TODO: MEM_ALLOC_SIZE_MB zamenit za db_mem_size_mb., nacitat jako SGA a PGA
-- tohle upravit dle aktualho stavu v OEM
CREATE OR REPLACE VIEW "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG" ("APP_NAME", "APP_CA_ID", "DB_EM_GUID", "INST_EM_GUID", "

select count(*) FROM "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG";


-- SYNCHRO_CA
--// OLI_OWNER.SYNCHRO_CA.reload_servers //--

```
  procedure reload_all AS
  BEGIN
    reload_applications;
    reload_databases;
    reload_servers;
  END reload_all;

exec OLI_OWNER.SYNCHRO_CA.reload_servers;

ORA-06512: at "OLI_OWNER.SYNCHRO_CA", line 151
ORA-06512: at "OLI_OWNER.SYNCHRO_CA", line 164

ERROR at line 1:
ORA-01427: single-row subquery returns more than one row
ORA-06512: at "OLI_OWNER.SYNCHRO_CA", line 151
ORA-06512: at line 1
```


-- RecoHUB

- OLIAPI_ORACLE_CMDB_CI
- OLIAPI_POSTGRES_CMDB_CI

-- OLAPI_APPS_DB_SERVERS_FARM_FLG

CREATE OR REPLACE VIEW "OLI_OWNER"."OLIAPI_ORACLE_CMDB_CI"
AS
SELECT DISTINCT
                   a.app_name,
                   A.CA_ID app_ca_id,
                   d.licdb_id || '-' || s.server_id AS DBINSTANCES_CK,
                   d.em_guid db_em_guid,
                   i.em_guid inst_em_guid,
                   D.DBNAME database_name,
                   i.inst_name instance_name,
                   i.inst_role instancerole,
                   ci.calc_percent as calc_percent_on_server,
                   i.dbinst_id,
                   i.ca_id as dbinst_cmdb_ci_id,
                   d.ca_id as db_cmdb_ci_id,
                   i.licdb_id oli_id,
                   i.server_id,
                   s.ca_id cmdb_ci_server,
                   s.hostname, s.domain,
                   decode(le.farm, 'Y', 'true', 'false') farm,
                   d.dbversion AS version,
                   d.env_status environment,
                   em.port tcp_port,
                   em.connect_descriptor,
                   decode(d.rac, 'Y', 'true', 'false') is_clustered,
                   decode(em.log_mode, 'ARCHIVELOG', 'true', 'false') backup,
                   em.db_size_mb,
                   em.db_log_size_mb,
                   emi.cpu,
                   emi.sga_size_mb sga_size_mb
     FROM OLI_OWNER.APPLICATIONS A,
          OLI_OWNER.APP_DB AD,
          OLI_OWNER.databases d,
          OLI_OWNER.DBINSTANCES i,
          OLI_OWNER.COST_CALC_DBINSTANCES ci,
          OLI_OWNER.servers s,
          OLI_OWNER.licensed_environments le,
          DASHBOARD.EM_DATABASE em,
          DASHBOARD.EM_INSTANCE emi
    WHERE     A.APP_ID = AD.APP_ID
          AND AD.LICDB_ID = D.LICDB_ID
          AND D.LICDB_ID = I.LICDB_ID
          AND i.server_id = s.server_id
          AND le.lic_env_id = s.lic_env_id
          and i.dbinst_id=ci.dbinst_id
          AND d.em_guid = em.em_guid(+)
          AND i.em_guid = emi.em_guid(+)
          ;


CREATE OR REPLACE VIEW "OLI_OWNER"."OLIAPI_POSTGRES_CMDB_CI"
AS
SELECT
   application app_name,
   instance database_instance,
       CASE
         WHEN hostname IN ('pedb01', 'bedb01') THEN 'pedb01,bedb01'
         WHEN hostname IN ('zpedb01', 'zbedb01') THEN 'zpedb01,zbedb01'
         ELSE hostname
       END
     hostname,
     'vs.csin.cz' domain,
       CASE
         WHEN hostname LIKE 'p%' THEN 'Production'
         WHEN hostname LIKE 'b%' THEN 'Production'
         WHEN hostname LIKE 'z%' THEN 'Pre-production'
         WHEN hostname LIKE 't%' THEN 'Test'
         WHEN hostname LIKE 'd%' THEN 'Development'
       END environment,
     vip,
     port tcp_port,
     NULL version,
     CASE
         WHEN hostname LIKE 'p%' THEN 'true'
         WHEN hostname LIKE 'b%' THEN 'true'
         WHEN hostname LIKE 'z%' THEN 'true'
         WHEN hostname LIKE 't%' THEN 'false'
         WHEN hostname LIKE 'd%' THEN 'false'
     END is_clustered,
     database database_name
FROM postgres.DATABASE
/
