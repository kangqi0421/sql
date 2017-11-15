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

-- ALL db v OLI
select count(*) from OLI_OWNER.DATABASES;

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
     ;
     
minus ;

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
