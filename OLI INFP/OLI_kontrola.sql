--
-- OLI checks
--

- procedura OLI_OWNER.CHECKS

-- databaze z OEM, ktere chybi v OLI
-- OEM
select d.database_name dbname
--  , host_name
--  from DASHBOARD.MGMT$TARGET
    FROM dashboard.MGMT$DB_DBNINSTANCEINFO d
      JOIN dashboard.MGMT$TARGET t ON d.target_guid = t.target_guid
 -- where t.CATEGORY_PROP_3 = 'DB'
 -- pouze Starbank
-- AND target_name like 'SD%'
minus
-- OLI
select upper(d.dbname) dbname
--       NVL2(DOMAIN, HOSTNAME||'.'||DOMAIN, HOSTNAME) host_name
FROM
     OLI_OWNER.DATABASES d
     JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
     JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
--where domain not like 'ack-prg%'  -- bez Karťáku
ORDER by 1;

-- OEM instance bez zaznamu v OLI
select upper(d.instance_name)
    FROM dashboard.MGMT$DB_DBNINSTANCEINFO d
      JOIN dashboard.MGMT$TARGET t ON d.target_guid = t.target_guid
  MINUS
select i.inst_name
FROM
    OLI_OWNER.DBINSTANCES i
ORDER by 1;

-- ALL targets db
select
    -- konverze podivných target name s podtržítkama
    case when instr(target_name, '_') > 0 THEN substr(target_name, 1, instr(target_name, '_')-1)
      ELSE target_name
    END dbname
    from DASHBOARD.ALL_MGMT_TARGETS
  where category_prop_3 = 'DB' -- pouze DB, bez RAC instancí
  -- AND target_name like 'ECRS%'
ORDER by 1;


-- servery bez alokace licencí
select * from  OLI_OWNER.SERVERS s
 where not exists (select 1 from LICENSE_ALLOCATIONS l where l.lic_env_id = s.lic_env_id)
 ;

-- RAC check
SELECT
  db.dbname, count(*)
FROM
  OLI_OWNER.DATABASES db
INNER JOIN OLI_OWNER.DBINSTANCES inst
ON
  db.LICDB_ID = inst.LICDB_ID
  where db.rac = 'Y'
  group by db.dbname
  --having count(*) < 2
order by db.dbname  ;

-- kontrola na servery bez licencí
-- ty jinak vypadnou z přehledu iSuurcingu
SELECT --count(*)
  INST_NAME
FROM
     OLI_OWNER.DATABASES d
     JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
     JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
     join OLI_OWNER.LICENSED_ENVIRONMENTS l on (s.lic_env_id = l.lic_env_id)
     join OLI_OWNER.DATACENTERS d on (d.datacenter_id = l.datacenter_id)
minus
SELECT
  i.INST_NAME
FROM
  --OLI_OWNER.OLAPI_LICENCE_USAGE_SUMMARY
  (SELECT min(s.server_id) server_id, min(s.HOSTNAME) hostname, min(s.domain) domain,
       min(P.CURRENT_PROD_NAME) CURRENT_PROD_NAME, p.current_prod_id,
       min(lt.lic_type_name) lic_type_name, la.lic_env_id,
       sum(C.CALC_PERCENT*LA.LIC_CNT_USED/100) CALC_LIC_CNT
  from OLI_OWNER.cost_aprox_lic_alloc_all_srv c,
     OLI_OWNER.license_allocations la,
     OLI_OWNER.PRODUCTS_W_CURRPROD P,
     OLI_OWNER.LICENSE_TYPES LT,
     OLI_OWNER.SERVERS S,
     OLI_OWNER.csi csi,
     OLI_OWNER.GLOBAL_CONTRACTS GC
where c.lic_alloc_id=la.lic_alloc_id
      AND P.PROD_ID=LA.PROD_ID
      AND C.SERVER_ID=S.SERVER_ID(+)
      AND LA.LIC_TYPE_ID=LT.LIC_TYPE_ID(+)
      and la.csi_id=csi.csi_id(+)
      and csi.contract_id=gc.contract_id(+)
      and CURRENT_PROD_NAME = 'Enterprise Edition'
      and db_product  = 'Y'
group by c.server_id, p.current_prod_id, la.lic_type_id, la.lic_env_id, gc.contract_id) L
    JOIN OLI_OWNER.products p ON (L.CURRENT_PROD_ID = p.prod_id)
    JOIN OLI_OWNER.DBINSTANCES i ON (i.server_id = l.server_id)
    JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
    left join OLI_OWNER.CA_SERVERS ca on (s.ca_id = ca.cmdb_ci_id)
    join OLI_OWNER.LICENSED_ENVIRONMENTS l on (s.lic_env_id = l.lic_env_id)
    LEFT join OLI_OWNER.DATACENTERS d on (d.datacenter_id = l.datacenter_id)
    JOIN OLI_OWNER.DATABASES d ON (d.licdb_id = i.licdb_id)
    LEFT JOIN (
       select licdb_id, LISTAGG(a.APP_NAME,',') WITHIN GROUP (ORDER BY a.app_id) app_name
         from OLI_OWNER.APPLICATIONS a join OLI_OWNER.APP_DB o ON (A.APP_ID = o.APP_ID)
        group by licdb_id) o ON (o.licdb_id = d.licdb_id)
 group by NVL2(rac_guid, rac_guid, target_guid)) log ON (LOG.GUID = D.EM_GUID)
;


-- APP bez licence na serveru
Vyznam sloupcu:
lic_cnt_used - pocet licenci dle licencni alokace
calc_lic_cnt - pocet licenci rozpocitavany na aplikace
diff - pocet licencni nerozpocitavanych na aplikace - idealne 0

Problem "servery bez databazi"
   hostnames - nazvy serveru bez databazi v danem lic. prostredi
   empty_percent - procento velikosti licencniho prostredi, ktere se nerozpocitava na aplikace kvuli chybejicimu serveru

Problem "databaze bez aplikaci/databaze ne zcela rozpocitavane na aplikace"
   miss_dbnames - nazvy nerozpocitavanych databazi a nerozpocitavane procento u kazde db
   db_miss_perc - procento lic. prostredi, ktere se nerozpocitava na aplikace kvuli chybejici aplikaci

diff2 - rozdil po eliminaci vlivu uvedenych problemu

select la.lic_alloc_id,
       /*p.CURRENT_PROD_ID,*/ p.CURRENT_PROD_NAME, /*lt.LIC_TYPE_ID,*/ lt.lic_type_name,
       le.lic_env_name,
       la.lic_cnt_used,
       round(c.calc_lic_cnt,2) calc_lic_cnt,
       round(nvl(la.lic_cnt_used,0) - nvl(c.calc_lic_cnt,0),2) diff,
       empty_srv.hostnames,
       empty_srv.empty_percent,
       miss_db.miss_dbnames,
       round(miss_db.miss_perc,2) db_miss_perc,
       round(la.lic_cnt_used - nvl(c.calc_lic_cnt,2)- (la.lic_cnt_used*nvl(empty_srv.empty_percent,0)/100)
                - (la.lic_cnt_used*nvl(miss_db.miss_perc,0)/100),2)  diff2
   from license_allocations la,
        products_w_currprod p,
        license_types lt,
        licensed_environments le,
        (select lic_alloc_id,sum(calc_lic_cnt) calc_lic_cnt, count(*) calc_row_cnt
            from license_costs_full group by lic_alloc_id) c,
        (select cs.lic_env_id,sum(cs.lic_env_calc_percent)  empty_percent,
                 listagg(utils.get_full_server_name(s.hostname,s.domain,s.dr_hw),', ') within group (order by s.hostname,s.domain) hostnames
              from COST_CALC_SRV_LIC_ENV cs, servers s, dbinstances i
              where cs.server_id=i.server_id(+) and i.server_id is null
                    and cs.server_id=s.server_id
              group by cs.lic_env_id) empty_srv,
        (select s.lic_env_id, listagg(x.dbname ||' ' || x.miss_db_percent ||'%',', ') within group (order by x.dbname) miss_dbnames,
             sum(s.LIC_ENV_CALC_PERCENT/100*i.CALC_PERCENT/100*x.miss_db_percent)  miss_perc
                  from (select d.licdb_id,min(d.dbname) dbname,100-sum(nvl(calc_percent,0)) miss_db_percent
                           from COST_CALC_APP_DB cd,databases d
                           where d.licdb_id=cd.licdb_id(+)
                           group by d.licdb_id
                           having round(sum(nvl(calc_percent,0)),2)!=100
                        ) x,cost_calc_dbinstances i, COST_CALC_SRV_LIC_ENV s
                  where x.licdb_id=i.licdb_id
                        and i.server_id=s.server_id
          group by s.lic_env_id) miss_db
   where la.lic_alloc_id=c.lic_alloc_id
         and la.prod_id=p.prod_id(+)
         and la.lic_type_id=lt.lic_type_id(+)
         and la.lic_env_id=le.lic_env_id(+)
         and la.lic_env_id=empty_srv.lic_env_id(+)
         and la.lic_env_id=miss_db.lic_env_id(+)
         and nvl(la.lic_cnt_used,0)!=round(nvl(c.calc_lic_cnt,0),2)
order by le.lic_env_name, p.current_prod_name;

