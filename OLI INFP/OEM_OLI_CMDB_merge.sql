-- DB version update
-- Lifecycle ENV_STATUS update

-- Notes:
--  - MAX je tam z duvodu duplicitnich targetu

-- kontrola na rozd�ln� EM_GUID
select oli.dbname, oli.em_guid,
       em.em_guid
  from   OLI_OWNER.databases oli
    JOIN DASHBOARD.EM_DATABASE em ON (oli.dbname = em.dbname)
where oli.em_guid <> em.em_guid
order by 1;

MERGE INTO
  OLI_OWNER.DATABASES oli
USING (
      select DB_NAME,
             db_target_guid
        from OLI_OWNER.OMS_DATABASES_MATCHING
       WHERE match_status in ('NX')
         -- zname duplicity Bohouše
         -- and db_name NOT in ('BRJ','ISS')
      ) em
ON (oli.dbname = em.db_name)
when matched then
  UPDATE set oli.em_guid = em.db_target_guid;

--
-- DB instance
--

-- DB Inst target GUID
select oli.inst_name,
       oli.em_guid oli_guid,
       em.em_guid
  from   OLI_OWNER.dbinstances oli
    JOIN DASHBOARD.EM_INSTANCE em
      ON upper(oli.inst_name) = upper(em.instance_name)
where oli.em_guid <> em.em_guid
order by oli.inst_name;

-- kontrola na rozd�ln� EM GUID u DB Instance
merge
 into OLI_OWNER.DBINSTANCES oli
USING (
    -- data z OEM
    select d.target_guid, d.instance_name
        from DASHBOARD.MGMT$DB_DBNINSTANCEINFO d
        JOIN DASHBOARD.MGMT$TARGET t ON d.target_guid = t.target_guid
        WHERE t.target_type = 'oracle_database'
          -- duplicity na instance name neresim, nutno opravit rucne
          AND instance_name NOT IN (
            select inst_name from OLI_OWNER.DBINSTANCES
            group by inst_name having count(*) > 1
         )
      ) oem
ON (upper(oli.inst_name) = upper(oem.instance_name))
when matched then
  update set oli.em_guid = oem.target_guid
;

-- kontrola na rozd�ln� EM_GUID
select
    oli.hostname,
    NVL2(oli.domain, oli.hostname ||'.'||oli.domain, oli.hostname),
    oli.em_guid,
    em.host_target_guid
  from   OLI_OWNER.SERVERS oli
    JOIN DASHBOARD.EM_HOSTS_V em
      ON (NVL2(oli.domain, oli.hostname ||'.'||oli.domain, oli.hostname) = em.hostname)
where oli.em_guid <> em.host_target_guid
order by 1;

-- server guid OEM > OLI
merge
 into OLI_OWNER.SERVERS oli
USING
  (SELECT
  oem.target_guid,
  SUBSTR(oem.host_name, 1, INSTR (oem.host_name, '.') - 1) hostname
FROM
  DASHBOARD.MGMT$TARGET oem
WHERE
  oem.target_type = 'host'
  --AND REGEXP_LIKE(oem.host_name, '(d|t|zp|p)ordb0[0-4].vs.csin.cz')
  -- and (oem.host_name NOT like '%dbzal%' AND oem.host_name NOT like 'dbtest%') -- duplicate server name
  ) oem
ON (oem.hostname = oli.hostname)
when matched then
update set oli.em_guid = oem.target_guid;

-- CMDB update SERVERS
merge
 into OLI_OWNER.SERVERS o
USING
  (SELECT
       hostname, domain, CMDB_CI_ID, HW_MODEL, logical_cpu, os
    FROM OLI_OWNER.ca_servers
   WHERE status = 'Alive'
     AND REGEXP_LIKE(hostname, '^[dt][pb][a-z]{3}db\d{2}')
   ) c
  ON (o.hostname = c.hostname
  AND o.domain = c.domain)
when matched then
  update set
    o.ca_id = c.cmdb_ci_id,
    o.HW_MODEL = c.HW_MODEL,
    o.logical_cpu = c.logical_cpu,
    o.os = c.os
;

-- update ARCHIVELOG mode
merge
 into OLI_OWNER.DATABASES o
USING
  (SELECT em_guid,
          decode(log_mode, 'ARCHIVELOG', 'Y', 'N') archivelog
        FROM DASHBOARD.EM_DATABASE
  ) d
ON (o.em_guid = d.em_guid)
when matched then
  update set o.archivelog = d.archivelog;
;

select *
  from   OLI_OWNER.databases
  where archivelog ='N';

-- CMDB update DATABASES
merge
 into OLI_OWNER.DATABASES o
USING
  (SELECT
  cmdb_ci_id,
  oli_licdb_id
FROM
  OLI_OWNER.CA_DATABASES
  ) c
ON (o.licdb_id = c.oli_licdb_id)
when matched then
  update set o.ca_id = c.cmdb_ci_id;
;

-- OLI_OWNER.DBINSTANCES
merge
 into OLI_OWNER.DBINSTANCES o
USING
  (SELECT
  dbinst_cmdb_ci_id,
  oli_dbinst_id
FROM
  OLI_OWNER.CA_DBINSTANCES
  ) c
ON (o.dbinst_id = c.oli_dbinst_id)
when matched then
  update set o.ca_id = c.dbinst_cmdb_ci_id;
;

