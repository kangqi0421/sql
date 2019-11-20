--------------------------------------------------------
--  DDL for View OLIAPI_POSTGRES_CMDB_CI
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "OLI_OWNER"."OLIAPI_POSTGRES_CMDB_CI" ("APP_NAME", "VIP", "HOSTNAME", "DOMAIN", "ENVIRONMENT", "TCP_PORT", "IS_CLUSTERED", "DATABASE") AS
  SELECT distinct
           application  app_name,
           vip,
           CASE
               WHEN vip like '%-prod-%'  THEN 'pppgsdb01,pbpgsdb01'
               WHEN vip like '%-pred-%'  THEN 'zppgsdb01,zbpgsdb01'
               WHEN vip like '%-tst-%'  THEN 'tppgsdb01'
               WHEN vip like '%-dev-%'  THEN 'dppgsdb01'
               ELSE ''
           END
               hostname,
           'vs.csin.cz'
               domain,
           CASE
               WHEN vip like '%-prod-%'  THEN 'Production'
               WHEN vip like '%-pred-%'  THEN 'Pre-production'
               WHEN vip like '%-tst-%'  THEN 'Test'
               WHEN vip like '%-dev-%'  THEN 'Development'
               else ''
           END
               environment,
           '5432'
               tcp_port,
           CASE
               WHEN vip like '%-prod-%'  THEN 'true'
               WHEN vip like '%-pred-%'  THEN 'true'
               WHEN vip like '%-tst-%'  THEN 'false'
               WHEN vip like '%-dev-%'  THEN 'false'
           END
               is_clustered,
           database
     FROM postgres.pg_DATABASE d, POSTGRES.PG_APPLICATION a
where regexp_replace(vip, 'vip-.*-','') = a.vip3(+)
;
