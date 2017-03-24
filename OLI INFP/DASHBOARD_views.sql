--
-- INFP
--

create user SVOBODA identified by abcd1234 profile prof_dba;
grant dba to SVOBODA;
grant dba to DKRCH;


db linky:
- INFTA - změněno na PUBLIC
CREATE PUBLIC DATABASE LINK "OEM_PROD" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMSP';
CREATE PUBLIC DATABASE LINK "OEM_TEST" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMST';


connect DASHBOARD/abcd1234

-- SLO

-- DB SIZE
-- pridat TYPE_QUALIFIER3 = 'DB' pouze pro db
-- posilat target guid i dbname ? nebo vyhodit mgmt$db_dbninstanceinfo ?
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_DATABASE_FRA_SIZE"
AS
SELECT
    d.target_guid,
    d.database_name dbname,
    round(s.value*1024) as db_size_mb,
    round(f.value/power(1024,2)) as db_log_size_mb
FROM
    mgmt$metric_current s
    JOIN mgmt$metric_current f ON (s.target_guid = f.target_guid)
    JOIN mgmt$db_dbninstanceinfo d ON (f.target_guid = d.target_guid)
    JOIN MGMT$TARGET t ON (d.target_guid = t.target_guid)
WHERE s.metric_name     = 'DATABASE_SIZE'
  AND s.metric_column   = 'ALLOCATED_GB'
  AND f.metric_name     = 'ha_flashrecovery'
  AND f.metric_column   = 'flash_recovery_area_size'
  -- pouze DB bez RAC instancí
  AND t.TYPE_QUALIFIER3 = 'DB'
ORDER BY d.database_name
;

-- MEM SIZE
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_INSTANCE_MEM_SIZE"
AS
SELECT
    d.target_guid,
    d.database_name dbname,
    d.instance_name,
    round(m.value) as db_mem_size_mb
FROM
    mgmt$metric_current m
    JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE m.metric_name     = 'memory_usage'
  AND m.metric_column   = 'total_memory'
ORDER BY d.database_name
;

-- DSN connect string
select t.target_guid,
   REDIM_GET_SHORT_NAME(t.target_name) AS dbname, -- orezane target name
   --target_name, target_type, host_name,
   machine.property_value hostname
   from DASHBOARD.MGMT$TARGET t
   JOIN DASHBOARD.MGMT$TARGET_PROPERTIES machine on (t.TARGET_GUID=machine.TARGET_GUID) -- machine
   where t.type_qualifier3     = 'DB'
   and   t.target_type         = 'oracle_database'
   AND   machine.PROPERTY_NAME = 'MachineName'

select distinct --d.target_name,
       rac_db_name, property_value
  from MGMT$TARGET_PROPERTIES p
       JOIN MGMT$RAC_TOPOLOGY t on (p.target_name = t.cluster_name)
       JOIN MGMT$DB_DBNINSTANCEINFO d on (t.db_instance_name = d.target_name)
  where 1=1
  --and d.target_name like 'DLKP%'
  and property_name = 'scanName'
  --and property_value like '%scan%'
order by 1;

select * from MGMT$RAC_TOPOLOGY t
  where cluster_name = 'ordb02-cluster'
    and db_instance_name like 'DLKP%';




--
-- "DASHBOARD"."EM_DBINST_SLO_V"
--
select
    dbracopt,
    envstatus,
    case
    -- produkce v RAC
    when (dbracopt = 'YES' and envstatus = 'Production')
              then 'Platinum'
    -- produkce v A/P clusteru
    when (dbracopt = 'NO' and envstatus = 'Production')
              then 'Gold'
    -- others = Bronze
    else 'Bronze'
  end SLO
  from DASHBOARD.EM_DBINSTANCES_V
;

--
-- select slo, pocet from DASHBOARD.EM_DBINST_SLO_V;
--

--
-- "DASHBOARD"."MGMT$DB_INIT_PARAMS"
--

connect DASHBOARD/abcd1234

CREATE OR REPLACE FORCE VIEW MGMT$METRIC_CURRENT AS
select
  *
from
  MGMT$METRIC_CURRENT@oem_prod
;

CREATE OR REPLACE FORCE VIEW "MGMT$DB_INIT_PARAMS" AS
select
  *
from
  MGMT$DB_INIT_PARAMS@oem_prod
;

CREATE OR REPLACE FORCE VIEW "MGMT$DB_DBNINSTANCEINFO"  AS
  select  *
from MGMT$DB_DBNINSTANCEINFO@oem_prod
;

CREATE OR REPLACE FORCE VIEW "CM$MGMT_ASM_CLIENT_ECM" AS
SELECT
  *
FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
;
