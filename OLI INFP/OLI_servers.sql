--
-- OLI_OWNER.SERVERS
--

define server = tgdwsrc1

-- OLI kontrola proti CMDB
select * from   OLI_OWNER.SERVERS
  where hostname like '&server%'
;

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
-- delete server
--

select l.lic_env_id,
       server_id, 
       multi_server
  from LICENSED_ENVIRONMENTS l
      inner join OLI_OWNER.SERVERS s
        on (l.lic_env_id = s.lic_env_id)
 WHERE hostname like 'tgdwsrc1'
;

delete from OLI_OWNER.SERVERS
   where lic_env_id = 3292
   and hostname = 'ppgmon01'
;

select * from OLI_OWNER.dbinstances 
  where server_id = 2831;

--
define server = todwsrc1

DECLARE
   p_hostname     VARCHAR2(200) := '&server' ;
   v_licdb_id     number;
   v_server_id    number;
   v_multi_server VARCHAR2(1);
BEGIN
  select l.lic_env_id, multi_server
      into v_licdb_id, v_multi_server
     from OLI_OWNER.LICENSED_ENVIRONMENTS l
        inner join OLI_OWNER.SERVERS s
          on (l.lic_env_id = s.lic_env_id)
   where lower(s.hostname) = lower(p_hostname);

  -- zruseni lic env, pokud to neni VMWare nebo AIX
  if v_multi_server = 'N' then
    DELETE from LICENSED_ENVIRONMENTS where lic_env_id = v_licdb_id;
  end if;

  DELETE from OLI_OWNER.SERVERS where server_id = v_server_id;
  delete from OLI_OWNER.dbinstances where server_id = v_server_id;  
  
exception
   when TOO_MANY_ROWS then
      raise_application_error(-20001, 'Multiple servers ' || p_hostname ||' exist in OLI');
   when NO_DATA_FOUND then
      raise_application_error(-20002, 'Server ' || p_hostname ||' not found in OLI');
END delete_database;
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
select NVL2(DOMAIN, HOSTNAME||'.'||DOMAIN, HOSTNAME) host_name from OLI_OWNER.SERVERS s
  where not exists (select 1 from LICENSE_ALLOCATIONS l where l.lic_env_id = s.lic_env_id)
minus
select NVL2(DOMAIN, HOSTNAME||'.'||DOMAIN, HOSTNAME) host_name from OLI_OWNER.CA_SERVERS
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