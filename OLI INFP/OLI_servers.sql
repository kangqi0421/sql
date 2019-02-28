--
-- OLI_OWNER.SERVERS
--

define server = pgtsmsta1

-- OLI kontrola proti CMDB
select * from   OLI_OWNER.SERVERS
  where 1 = 1
--    AND hostname like '&server%'
   AND domain = 'cc.csin.cz'
   --AND hostname in ('zgdwhdb1')
   and failover_server_id = 695

;

-- update failover serveru
UPDATE SERVERS set failover_server_id = NULL where  hostname like 'z%dwmdb1';

-- pridani targetu
-- nutno zadat LIC_ENV_ID - jinak neprojde přidání serveru

-- Lic Env

select *
  from LICENSED_ENVIRONMENTS
 WHERE 1 = 1
--   AND lic_env_name like 'ORACLE%';
   AND lic_env_name like '&server%';

--
-- Insert do OLI_OWNER.SERVERS
--

define lic_env_id = 3292

-- konkrotni server
INSERT into OLI_OWNER.SERVERS (HOSTNAME, DOMAIN, DR_HW, SPARE, LIC_ENV_ID)
  VALUES('dpclmdb01', 'vs.csin.cz', 'N', 'N', &lic_env_id);


--
select * from OLI_OWNER.OMS_HOSTS;

select lic_env_id, lic_env_name
  from LICENSED_ENVIRONMENTS
 WHERE lic_env_name like '%PA802%';


-- update lic env ID pro Starbank
UPDATE OLI_OWNER.SERVERS
    set lic_env_id = (select lic_env_id
  from LICENSED_ENVIRONMENTS
 WHERE lic_env_name like 'PA802_Oracle')
  where hostname like 'tasb%';

--
-- API delete server, vcetne lic env
--

  select     l.lic_env_id, l.multi_server, s.server_id,
      OLIFQDN(lower(s.hostname), lower(s.domain))
        -- into   v_licdb_id, v_multi_server, v_server_id
     from OLI_OWNER.LICENSED_ENVIRONMENTS l
        inner join OLI_OWNER.SERVERS s
          on (l.lic_env_id = s.lic_env_id)
   where OLIFQDN(lower(s.hostname), lower(s.domain)) like 'todwsrc1%';

delete from OLI_OWNER.SERVERS
   where server_id = 2831
;

select * from OLI_OWNER.dbinstances
  where server_id = 2831;

--
define server = dprmddb01
                tprmddb01

--
-- delete server vcetne cascade options na db instance


BEGIN
for rec in (
    select hostname, domain from OLI_OWNER.SERVERS
      where hostname in (
      'dprmddb01'
        )
           )
  LOOP
    api_delete_server(OLIFQDN(lower(rec.hostname), lower(rec.domain)));
  END loop;
END;
/


--
-- vloz VMWare servery
INSERT into OLI_OWNER.SERVERS (HOSTNAME, DOMAIN, DR_HW, SPARE,
     LIC_ENV_ID, EM_GUID,
     CA_ID, HW_MODEL, LOGICAL_CPU, OS)
SELECT
    regexp_replace(o.hostname, '^(\w+)(\.\w+)*$', '\1') hostname,
    regexp_replace(o.hostname, '^\w+\.(.+?\.)', '\1')     domain,
    'N' DR_HW, 'N' SPARE,
    &lic_env_id,
    o.HOST_TARGET_GUID,
    c.CMDB_CI_ID, c.HW_MODEL, c.logical_cpu, c.os
  from OLI_OWNER.OMS_HOSTS_MATCHING o LEFT JOIN OLI_OWNER.ca_servers c
          on (regexp_replace(o.hostname, '^(\w+)(\.\w+)*$', '\1') = c.hostname
          AND regexp_replace(o.hostname, '^\w+\.(.+?\.)', '\1')   = c.domain)
 where match_status in ('U')
   and c.hostname like 'dpora%'
   -- and REGEXP_LIKE(o.hostname, '^[dt][pb][a-z]{3}db\d{2}')
;

-- OLI check: server bez SERVERu v CMDB
-- servery v OLI, ktere neexistuji v CMDB
select lower(OLIFQDN(hostname, domain)) host_name from OLI_OWNER.SERVERS s
  where not exists (select 1 from LICENSE_ALLOCATIONS l where l.lic_env_id = s.lic_env_id)
minus
select lower(OLIFQDN(hostname, domain)) host_name from OLI_OWNER.CA_SERVERS
;


select * from   OLI_OWNER.CA_SERVERS
  where lower(hostname) like 'dpddmdb01%'
;

select * from CA_SERVERS
  where resource_name = 'HSLV_tpraddb01.vs.vsin.cz'
;

select * from   OLI_OWNER.CA_SRC_SERVERS
 where hostname like 'dpddmdb01%'
;