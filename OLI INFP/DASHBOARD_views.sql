--
-- INFP
--

create user SVOBODA identified by abcd1234 profile prof_dba;
grant dba to SVOBODA;
grant dba to DKRCH;


db linky:
CREATE DATABASE LINK "OEM_PROD" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMSP';
CREATE DATABASE LINK "OEM_TEST" CONNECT TO CONS IDENTIFIED BY Abcd1234 USING 'OMST';



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
CREATE OR REPLACE FORCE VIEW "DASHBOARD"."MGMT$DB_INIT_PARAMS" AS
select
  *
from
  MGMT$DB_INIT_PARAMS@oem_prod
;

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."CM$MGMT_ASM_CLIENT_ECM" AS
SELECT
  *
FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
;

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."MGMT$DB_DBNINSTANCEINFO"  AS
  select  *
from MGMT$DB_DBNINSTANCEINFO@oem_prod
;
