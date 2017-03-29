--
-- iSourcing extract
--

- před exportem prov0st kontroly dle OLI_kontrola.sql
- před exportem provést sync emguid a verzí

- licence
   - NUP se již nevykazuje, vše jako PP
   - NUP se vykazuje jako PP = NUP/10

- Service Levels
  - Platinum má pouze produkce v RAC,
  - A/P clustery produkce jsou Gold
  - Na Silver kašlu v
  - zbytek je Bronze.

-- report SQL serveru - zrušeno
http://reports12.csin.cz/Reports/Pages/Report.aspx?ItemPath=%2fDashBoard%2fOracleSlo

-- zjednodusena verze, pouze SL
select SL, count(*)
from
(
select
    case
    -- produkce v RAC
    when (d.rac = 'Y' and env_status = 'Production')
              then 'Platinum'
    -- produkce v A/P clusteru
    when  env_status = 'Production'
              then 'Gold'
    -- others = Bronze
    else 'Bronze'
  end SL
FROM
     OLI_OWNER.DATABASES d
     JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
)
group by SL
order by SL DESC ;

select sl, count(*) from (
SELECT
--  count(*) cnt
  ca.sn,
  app_name,
  i.INST_NAME,
  decode(dc.country,'CZ','Czech Republic','AT','Austria',dc.country) "DC location country",
  env_status "Business environment",
  'Database' as "Application environment",
  'Oracle' as Platform,
  NVL(DBVersion, '11.2') DBVersion,   --pokud verze chybi, uved 11.2 ;-)
  1,'N/A','N/A','N/A',
  s.OS,
  NVL2(s.DOMAIN, s.HOSTNAME||'.'||s.DOMAIN, s.HOSTNAME) "server",
  dbs.alloc_gb,
  'Enterprise Edition' CURRENT_PROD_NAME,
  -- vše na PP, hodnota NUP/10
  'PP' lic_type_name,
  --round(lic_cnt_used) lic_cnt_used,
  -- connections - všude dávat NULL
  NULL "avg_conn",
  --case when L.lic_type_name = 'NUP' then log.LOGONS ELSE NULL END "avg_conn"
  NULL, NULL, NULL,
  -- service Levels
  case
    -- produkce v RAC
    when (d.rac = 'Y' and env_status = 'Production')
              then 'Platinum'
    -- produkce v clusteru
    when  env_status = 'Production'
              then 'Gold'
    -- vše ostatní je Bronze
    else 'Bronze'
  end SL
FROM
  OLI_OWNER.DATABASES d
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
  left join OLI_OWNER.CA_SERVERS ca on (ca.cmdb_ci_id = s.ca_id)
  -- LICENCE USAGE
  LEFT JOIN (
      select lic_env_id,
             decode(LIC_TYPE_ID,2,'NUP',3,'PP') lic_type,
             sum(decode(LIC_TYPE_ID,2,lic_cnt_used/10,3,lic_cnt_used)) lic_cnt_used
          from OLI_OWNER.license_allocations
      where active = 'Y'
        and prod_id in (33,38)  -- Enterprise Edition
      group by  lic_env_id, decode(LIC_TYPE_ID,2,'NUP',3,'PP')
            ) l ON (l.lic_env_id = s.lic_env_id)
    --JOIN OLI_OWNER.products p ON (L.CURRENT_PROD_ID = p.prod_id)
    join OLI_OWNER.LICENSED_ENVIRONMENTS l on (s.lic_env_id = l.lic_env_id)
    LEFT join OLI_OWNER.DATACENTERS dc on (dc.datacenter_id = l.datacenter_id)
    -- nazev aplikace
    LEFT JOIN (
       select licdb_id, LISTAGG(a.APP_NAME,',') WITHIN GROUP (ORDER BY a.app_id) app_name
         from OLI_OWNER.APPLICATIONS a join OLI_OWNER.APP_DB o ON (A.APP_ID = o.APP_ID)
        group by licdb_id) o ON (o.licdb_id = d.licdb_id)
    -- current logons
    LEFT JOIN (select NVL2(rac_guid, rac_guid, target_guid) guid, max(logons) logons from SRBA.MGMT_LOGONS
 group by NVL2(rac_guid, rac_guid, target_guid)) log ON (LOG.GUID = D.EM_GUID)
    -- allocated space
    LEFT JOIN (select target_guid, round(max(maximum)) alloc_gb from dashboard.mgmt$metric_daily
        WHERE     metric_column = 'ALLOCATED_GB' and rollup_timestamp > sysdate - 7
               group by target_guid) dbs on (dbs.target_guid = d.em_guid)
WHERE 1=1
    -- exception, co nechci do vypisu
--    AND d.dbname not in ('COGD', 'COGT','TS8D')
--and env_status = 'srvok'
--  AND SN IS NULL
--  and s.HOSTNAME like '%aix%'
--    AND d.em_guid is NULL
--    AND L.lic_type_name = 'NUP'  AND log.LOGONS is NULL
--    AND app_name like '%EIGER%'
--    AND d.rac = 'Y'
--    and d.dbname= 'RMAN'
--    and s.os is NULL
--and dbs.alloc_gb is NULL
ORDER BY upper(INST_NAME)
)
group by sl order by 1 desc;


-- 458  rows exported
-- 601 rows exported
-- 615 rows exported

-- kontrola na
select target_name, target_type, target_guid
  from DASHBOARD.MGMT$TARGET
--    DASHBOARD.MGMT_TARGETS
 where
 target_name like '%BMWDB%'
-- target_guid = 'E0E30DF24B1A7C2C491DA5718924233A'
 ;

