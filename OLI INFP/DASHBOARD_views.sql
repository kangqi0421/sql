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


-- SLO

-- DB SIZE
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_DATABASE_SIZE"
AS
SELECT
    d.database_name dbname,
    round(max(m.value)) as size_gb
FROM
    mgmt$metric_current m
    JOIN mgmt$db_dbninstanceinfo d ON (
        m.target_guid = d.target_guid
    )
WHERE m.metric_name = 'DATABASE_SIZE'
  AND m.metric_column = 'ALLOCATED_GB'
GROUP BY d.database_name
;

-- MEM SIZE
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_DATABASE_SIZE"
mgmt$metric_current
'memory_usage'


--
-- "DASHBOARD"."EM_DBINST_SLO_V"
--

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."EM_DBINST_SLO_V"
AS
select SLO, count(*) pocet
from
(select
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
)
group by SLO
order by SLO desc
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
