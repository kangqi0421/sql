select * from all_views
where view_name like 'OLAPI%';

--
-- používaná view

select * from OLI_OWNER.OLAPI2_APPS_DB_SRVS_FARM_FLG;
select * from OLI_OWNER.OLAPI_ACQUIRED_LICENSES;
select * from OLI_OWNER.OLAPI_LICENCE_USAGE_DETAIL;

-- ostatné view
select * from OLI_OWNER.OLAPI_DATABASES;
select * from OLI_OWNER.OLAPI_DBINSTANCES;
select * from OLI_OWNER.OLAPI_SERVERS;

select * from OLI_OWNER.OLAPI_APPLICATIONS;
select * from OLI_OWNER.OLAPI_APP_DB;
select * from OLI_OWNER.OLAPI_LICENSED_ENVIRONMENTS;

-- definice OLAPI2_APPS_DB_SRVS_FARM_FLG;
--
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "OLI_OWNER"."OLAPI2_APPS_DB_SRVS_FARM_FLG" ("APP_NAME", "APP_CA_ID", "INST_NAME", "INST_ROLE", "PERCENT_ON_SERVER", "DBINST_ID", "DBINST_CMDB_CI_ID", "DBNAME", "DB_CMDB_CI_ID", "RAC", "DB_VERSION", "ENV_STATUS", "LICDB_ID", "SERVER_ID", "SERVER_CA_ID", "HOSTNAME", "DOMAIN", "FARM", "DBINSTANCES_CK") AS
  SELECT DISTINCT  a.app_name,
                   A.CA_ID app_ca_id,
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
                   d.licdb_id || '-' || s.server_id AS DBINSTANCES_CK
     FROM oli_owner.APPLICATIONS A,
          oli_owner.APP_DB AD,
          oli_owner.databases d,
          oli_owner.DBINSTANCES i,
          oli_owner.servers s,
          oli_owner.licensed_environments le
    WHERE     A.APP_ID = AD.APP_ID
          AND AD.LICDB_ID = D.LICDB_ID
          AND D.LICDB_ID = I.LICDB_ID
          AND i.server_id = s.server_id
          AND le.lic_env_id = s.lic_env_id;