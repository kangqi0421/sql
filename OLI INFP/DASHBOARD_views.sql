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
  host_name,
  target_name,
  target_type,
  target_guid,
  collection_timestamp,
  name,
  isdefault,
  value,
  datatype
from
  MGMT$DB_INIT_PARAMS@oem_prod
;

CREATE OR REPLACE FORCE VIEW "DASHBOARD"."CM$MGMT_ASM_CLIENT_ECM" AS
SELECT
  cm_target_guid,
  cm_target_type,
  cm_target_name,
  cm_snapshot_type,
  last_collection_timestamp,
  ECM_SNAPSHOT_ID,
  DISKGROUP,
  INSTANCE_NAME,
  DB_NAME
FROM CM$MGMT_ASM_CLIENT_ECM@oem_prod
;
