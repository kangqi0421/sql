--
-- OLIAPI CA CMDB view
--

-- TODO: založit ownera OLI_API ? -> zneužijeme dashboard
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
   server_id := OLI_API.ADD_SERVER('tpdwhdb01.vs.csin.cz');
   dbms_output.put_line('server_id: ' || server_id);
END;
/
commit;

-- add db - zatím nefunguje
set serveroutput on
DECLARE
   licdb_id INTEGER;
BEGIN
   licdb_id := OLI_API.add_database('DWHPOC', 'DWH');
   dbms_output.put_line('licdb_id: ' || licdb_id);
END;
/
commit;


call OLI_API.delete_database('TS2O');

select 'call OLI_API.delete_database('|| DBMS_ASSERT.enquote_literal(d.dbname) ||');' as cmd
  from OLI_OWNER.DATABASES d
 where d.dbname like 'TS2%';

call OLI_API.delete_database('TS2O');
call OLI_API.delete_database('TS2B');
call OLI_API.delete_database('TS2I');

-- delete server ???
tbsb2o.vs.csin.cz
tbsb2i.vs.csin.cz

-- ERROR
delete from databases where licdb_id = 91
Error report -
ORA-02292: integrity constraint (OLI_OWNER.DB_APP_DATABASES_FK) violated - child record found

-- OLAP views

select * from all_views
where view_name like 'OLAPI%';

-- základní data do CMDB
select * from OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG;

-- Sync OLI
SyncOLI používá 3 pohledy:
OLAPI_APPS_DB_SERVERS_FARM_FLG
OLAPI_ACQUIRED_LICENSES
OLAPI_LICENCE_USAGE_DETAIL

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

-- definice OLAPI2_APPS_DB_SRVS_FARM_FLG;
-- nahradit za OLAPI_APPS_DB_SERVERS_FARM_FLG
--
-- TODO: MEM_ALLOC_SIZE_MB zamenit za db_mem_size_mb., nacitat jako SGA a PGA
-- tohle upravit dle aktualho stavu v OEM
CREATE OR REPLACE VIEW "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG" ("APP_NAME", "APP_CA_ID", "DB_EM_GUID", "INST_EM_GUID", "INST_NAME", "INST_ROLE", "PERCENT_ON_SERVER", "DBINST_ID", "DBINST_CMDB_CI_ID", "DBNAME", "DB_CMDB_CI_ID", "RAC", "DB_VERSION", "ENV_STATUS", "LICDB_ID", "SERVER_ID", "SERVER_CA_ID", "HOSTNAME", "DOMAIN", "FARM", "DBINSTANCES_CK", "LOG_MODE", "CHARACTERSET", "SL_MIN", "SLA", "DSN", "DB_SIZE_MB", "DB_LOG_SIZE_MB", "CPU", "MEM_ALLOC_SIZE_MB") AS
  SELECT DISTINCT    a.app_name,
                   A.CA_ID app_ca_id,
                   d.EM_GUID DB_EM_GUID,
                   I.EM_GUID INST_EM_GUID,
                   I.INST_NAME,
                   I.INST_ROLE,
                   ci.calc_percent as PERCENT_ON_SERVER,
                   I.DBINST_ID,
                   I.CA_ID as DBINST_CMDB_CI_ID,
                   D.DBNAME,
                   D.CA_ID as DB_CMDB_CI_ID,
                   d.rac,
                   d.dbversion AS db_version,
                   d.env_status,
                   I.LICDB_ID,
                   I.SERVER_ID,
                   s.ca_id server_ca_id,
                   S.HOSTNAME,
                   s.domain,
                   le.farm,
                   d.licdb_id || '-' || s.server_id AS DBINSTANCES_CK,
                   em.log_mode,
                   em.characterset,
                   em.SL_MIN,
                   CASE
                     when (d.rac = 'Y' and d.env_status = 'Production')
                          then 'Platinum'
                     -- produkce v A/P clusteru
                     when (d.rac = 'N' and d.env_status = 'Production')
                          then 'Gold'
                     -- others = Bronze
                     else 'Bronze'
                   end SLA,
                   NVL2(em.server_name, em.server_name||':'
                          ||em.port||'/'||em.dbname, NULL) AS DSN,
                   em.db_size_mb,
                   em.db_log_size_mb,
                   emi.cpu,
                   emi.sga_size_mb MEM_ALLOC_SIZE_MB
     FROM oli_owner.APPLICATIONS A,
          oli_owner.APP_DB AD,
          oli_owner.databases d,
          oli_owner.DBINSTANCES i,
          OLI_OWNER.COST_CALC_DBINSTANCES ci,
          oli_owner.servers s,
          oli_owner.licensed_environments le,
          DASHBOARD.EM_DATABASE em,
          DASHBOARD.EM_INSTANCE emi
    WHERE     A.APP_ID = AD.APP_ID
          AND AD.LICDB_ID = D.LICDB_ID
          AND D.LICDB_ID = I.LICDB_ID
          AND i.server_id = s.server_id
          AND le.lic_env_id = s.lic_env_id
          and i.dbinst_id=ci.dbinst_id
          AND d.em_guid = em.em_guid(+)
          AND i.em_guid = emi.em_guid(+);
;


select count(*) FROM "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG";


-- SYNCHRO_CA
--// OLI_OWNER.SYNCHRO_CA.reload_servers //--

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

exec OLI_OWNER.SYNCHRO_CA.reload_all;


     UPDATE ca_servers cs
         SET (virt_platform_resource_name,virt_platform_display_name,virt_platform_ci_id)=
            (SELECT cv.resource_name cv_resource_name, cv.display_name cv_display_name, cv.cmdb_ci_id cv_cmdb_ci_id
                FROM ca_relations cr, ca_virt_platforms cv
                WHERE (cs.cmdb_ci_id=cr.child_cmdb_ci_id and cr.rel_type='hosts')
                      and (cr.parent_cmdb_ci_id=cv.cmdb_ci_id)
           );
