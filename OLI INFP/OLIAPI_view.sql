--
-- OLIAPI view
--

select * from all_views
where view_name like 'OLAPI%';

-- základní data do CMDB
select * from OLI_OWNER.OLAPI_APPS_DB_SERVERS_FARM_FLG;


-- Alešova původní view
select * from OLI_OWNER.OLAPI_ACQUIRED_LICENSES;
select * from OLI_OWNER.OLAPI_LICENCE_USAGE_DETAIL;
-- již se nepoužívá, mělo by být nahraženo za moje
select * from OLI_OWNER.OLAPI2_APPS_DB_SRVS_FARM_FLG;


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

-- granty na DASHBOARD view WITH GRANT option
GRANT SELECT ON DASHBOARD.MGMT$DB_DBNINSTANCEINFO TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$TARGET_PROPERTIES TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$TARGET TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$METRIC_CURRENT TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$METRIC_HOURLY TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.MGMT$DB_INIT_PARAMS TO OLI_OWNER with GRANT option;

GRANT SELECT ON DASHBOARD.EM_DATABASE_INFO TO OLI_OWNER with GRANT option;
GRANT SELECT ON DASHBOARD.EM_INSTANCE_CPU_MEM_SIZE TO OLI_OWNER with GRANT option;

-- definice OLAPI2_APPS_DB_SRVS_FARM_FLG;
-- nahradit za OLAPI_APPS_DB_SERVERS_FARM_FLG
CREATE OR REPLACE FORCE VIEW "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG"
AS
SELECT DISTINCT    a.app_name,
                   A.CA_ID app_ca_id,
                   d.EM_GUID DB_EM_GUID,
                   I.EM_GUID INST_EM_GUID,
                   I.INST_NAME,
                   I.INST_ROLE,
                   I.PERCENT_ON_SERVER,
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
                   emi.MEM_ALLOC_SIZE_MB
     FROM oli_owner.APPLICATIONS A,
          oli_owner.APP_DB AD,
          oli_owner.databases d,
          oli_owner.DBINSTANCES i,
          oli_owner.servers s,
          oli_owner.licensed_environments le,
          DASHBOARD.EM_DATABASE_INFO em,
          DASHBOARD.EM_INSTANCE_CPU_MEM_SIZE emi
    WHERE     A.APP_ID = AD.APP_ID
          AND AD.LICDB_ID = D.LICDB_ID
          AND D.LICDB_ID = I.LICDB_ID
          AND i.server_id = s.server_id
          AND le.lic_env_id = s.lic_env_id
          AND d.em_guid = em.em_guid(+)
          AND i.em_guid = emi.em_guid(+)
;

select count(*) FROM "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG";