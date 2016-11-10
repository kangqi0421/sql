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

select slo, pocet from DASHBOARD.EM_DBINST_SLO_V;