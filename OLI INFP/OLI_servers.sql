--
-- OLI_OWNER.SERVERS
--


-- pridani targetu
-- nutno zadat LIC_ENV_ID - jinak neprojde přidání serveru

-- Lic Env

select *
  from LICENSED_ENVIRONMENTS
 WHERE lic_env_name like 'ORACLE%';

--
-- Insert do OLI_OWNER.SERVERS
--

3292: ORACLE-02-ANT (VMAX3)

define lic_env_id = 3292

-- konkrotni server
INSERT into OLI_OWNER.SERVERS (HOSTNAME, DOMAIN, DR_HW, SPARE, LIC_ENV_ID)
  VALUES('dpclmdb01', 'vs.csin.cz', 'N', 'N', &lic_env_id);


--
select * from OLI_OWNER.OMS_HOSTS;

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
 where REGEXP_LIKE(o.hostname, '^[dt][pb][a-z]{3}db\d{2}')
   and match_status in ('U')
;

--
SELECT
    CASE
      WHEN OS LIKE 'AIX%' THEN 'AIX'
      WHEN OS LIKE 'HP-UX%'  THEN 'HP-UX'
      WHEN OS LIKE '%Windows%' THEN 'Microsoft Windows Server'
      WHEN OS LIKE 'RHEL%'  THEN 'Linux'
      WHEN OS LIKE 'CentOS%'  THEN 'Linux'
      WHEN OS LIKE 'SOLARIS%'  THEN 'SOLARIS'
      ELSE OS
    END "OS"
  FROM OLI_OWNER.SERVERS;
