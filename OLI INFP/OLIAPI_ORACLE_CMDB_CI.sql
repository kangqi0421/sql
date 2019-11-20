--------------------------------------------------------
--  DDL for View OLIAPI_ORACLE_CMDB_CI
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "OLI_OWNER"."OLIAPI_ORACLE_CMDB_CI" ("APP_NAME", "APP_CA_ID", "DBINSTANCES_CK", "DB_EM_GUID", "INST_EM_GUID", "DATABASE_NAME", "INSTANCE_NAME", "INSTANCEROLE", "CALC_PERCENT_ON_SERVER", "DBINST_ID", "DBINST_CMDB_CI_ID", "DB_CMDB_CI_ID", "OLI_ID", "SERVER_ID", "CMDB_CI_SERVER", "HOSTNAME", "DOMAIN", "FARM", "VERSION", "ENVIRONMENT", "TCP_PORT", "CONNECT_DESCRIPTOR", "IS_CLUSTERED", "BACKUP", "DB_SIZE_MB", "DB_LOG_SIZE_MB", "CPU", "SGA_SIZE_MB") AS
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
