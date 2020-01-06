--
-- OLI_OWNER.SERVERS
--

define server = bordb03

-- OLI kontrola proti CMDB
select * from   OLI_OWNER.SERVERS
  where 1 = 1
    AND hostname like '&server%'
--   AND domain = 'cc.csin.cz'
   --AND hostname in ('zgdwhdb1')
--   and failover_server_id = 695
;

-- počet CPU
select hostname, domain, status, cpu_cores, hyperthreading
   from   OLI_OWNER.CA_SERVERS
  where 1 = 1
    AND hostname like '&server%'
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

define aix_box = "PA811%"
define server = "dasb%"

select lic_env_id, lic_env_name
  from LICENSED_ENVIRONMENTS
 WHERE lic_env_name like '&aix_box';


select * from OLI_OWNER.SERVERS
  where hostname like '&server';

-- update lic env ID pro Starbank
UPDATE OLI_OWNER.SERVERS
    set lic_env_id = (select lic_env_id
  from LICENSED_ENVIRONMENTS
 WHERE lic_env_name like '&aix_box')
  where hostname like '&server';

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


select * from SERVERS
  where lower(hostname) like 'dporadb01%'
;

select
  -- *
  s.CMDB_CI_ID,s.hw_model,s.logical_cpu,s.os, s.virt_platform_ci_id,
  s.virt_platform_display_name, s.status
   from CA_SERVERS s
  where lower(hostname) like 'eporadb01%'
;

select
  -- *
    from CA_SRC_SERVERS
  where "u_hostname" like 'eporadb01%'
  ;

-- server včetně cluster name

-- vazba na clustery
- parent = server
- child = VMW cluster

AIX: pool (child) - lpar (parent)

- Parent - The entity on the "one" (/1) side of a relation with another table
- Child - The entity on the "many" (/N/) side of a relation with another table

select cs.hostname, cv.resource_name, cr.rel_type
    from CA_SERVERS cs
    left join ca_relations cr on (cs.cmdb_ci_id = cr.parent_cmdb_ci_id)
    left join ca_virt_platforms cv on (cr.child_cmdb_ci_id = cv.cmdb_ci_id)
  where 1 = 1
    and cs.hostname like 'pp1vmw%'
    and cv.display_name like 'ORACLE-01-ANT'
    -- and cv.display_name like 'PB901-PowerHA-ORA'
 order by 1;

-- otočené vazby, tj. HW server (child) - AIX Pool / VMWare server (parent)

AIX:  rel_type: d93304fb0a0a0b78006081a72ef08444
VMWAre: a99d39118f10310091769012cbbe4429

  RELATION_SERVER_CLUSTER VARCHAR2(40) := 'a99d39118f10310091769012cbbe4429';
  RELATION_CLUSTER_AIX VARCHAR2(40) := 'd93304fb0a0a0b78006081a72ef08444';

select cs.hostname, cv.resource_name, cr.rel_type
    from CA_SERVERS cs
    left join CA_RELATIONS cr on (cs.cmdb_ci_id = cr.child_cmdb_ci_id)
    left join CA_VIRT_PLATFORMS cv on (cr.parent_cmdb_ci_id = cv.cmdb_ci_id)
  where 1 = 1
    -- and cs.hostname like 'pp1vmw%'
    and cv.display_name like 'ORACLE-01-ANT'
    -- and cv.display_name like 'PB901-PowerHA-ORA'
 order by 1;

-- relation to CLUSTER

select * from ca_virt_platforms
  where resource_name like 'HVP_ORACLE%'
  -- where resource_name like 'HVP_PB805-oracle'
--  where resource_name like 'HVP_PB9%'
;

CA_VIRT_PLATFORMS
sys_id  name cpu
a7915576dbee5780f127fbc61d961945  ORACLE-01-BUD 72
2b915576dbee5780f127fbc61d961947  ORACLE-01-ANT 448
fb919576dbee5780f127fbc61d96199d  ORACLE-02-ANT 96

585eee1adbc504102070f5b31d9619cb  PB901-PowerHA-ORA

relation type:
a99d39118f10310091769012cbbe4429 - cluster
5f985e0ec0a8010e00a9714f2a172815 - server

ca_servers:
f8141a18dbb237c49a56fc7c0c96191d  pb901

Vaclavíková:
Tj HW server (child) - Pool (parent)
Pool (child) - lpar (parent)

    SELECT
        "type",
        "child",
        "parent"
    FROM CA_SRC_RELATIONS
     where "child" = 'c8a19576dbee5780f127fbc61d9619e1';

-- vazba na VMWare cluster

- child = VMWare cluster
- parent = server

select * from ca_relations
  where p_name like 'HVP_ORACLE%';

select * from ca_relations;

HSLV_dpdetdb01.vs.csin.cz
HSLV_dprtodb01.vs.csin.cz

Hosted on -VMware vCenter Clusters
[L1]HVP_ORACLE-01-ANTStatus: Active

VMware Virtual Platform

-- procedure sync_farm_hosts is
select * FROM farm_hosts;

-- T5
select * FROM farm_hosts
  where cpu_type like 'SPARC%';