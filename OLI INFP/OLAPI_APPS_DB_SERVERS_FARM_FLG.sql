--------------------------------------------------------
--  DDL for View OLAPI_APPS_DB_SERVERS_FARM_FLG
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "OLI_OWNER"."OLAPI_APPS_DB_SERVERS_FARM_FLG" ("APP_NAME", "APP_CA_ID", "DB_EM_GUID", "INST_EM_GUID", "INST_NAME", "INST_ROLE", "PERCENT_ON_SERVER", "DBINST_ID", "DBINST_CMDB_CI_ID", "DBNAME", "DB_CMDB_CI_ID", "RAC", "DB_VERSION", "ENV_STATUS", "LICDB_ID", "SERVER_ID", "SERVER_CA_ID", "HOSTNAME", "DOMAIN", "FARM", "DBINSTANCES_CK", "LOG_MODE", "CHARACTERSET", "SL_MIN", "SLA", "DSN", "DB_SIZE_MB", "DB_LOG_SIZE_MB", "CPU", "MEM_ALLOC_SIZE_MB") AS
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
          AND i.em_guid = emi.em_guid(+)
;
