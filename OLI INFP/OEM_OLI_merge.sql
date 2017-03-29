-- DB version update
-- Lifecycle ENV_STATUS update
PoznÃ¡mky:
- MAX je tam z duvodu duplicitnich targetu

-- kontrola na rozdílná EM_GUID
select oli.dbname, oli.em_guid,
       d.target_guid
  from   OLI_OWNER.databases oli
    JOIN DASHBOARD.MGMT$DB_DBNINSTANCEINFO d ON oli.dbname = d.database_name
    JOIN DASHBOARD.MGMT$TARGET t ON d.target_guid = t.target_guid
where t.TYPE_QUALIFIER3 = 'DB'    -- mimo RAC
  and oli.em_guid <> d.target_guid
order by 1;

-- DB Inst target GUID
select oli.inst_name, oli.em_guid,
       d.target_guid
  from   OLI_OWNER.dbinstances oli
    JOIN DASHBOARD.MGMT$DB_DBNINSTANCEINFO d
      ON upper(oli.inst_name) = upper(d.instance_name)
    JOIN DASHBOARD.MGMT$TARGET t ON d.target_guid = t.target_guid
       -- pouze DB instance bez RAC database
where  t.target_type = 'oracle_database'
    AND oli.em_guid <> d.target_guid
order by oli.inst_name;

-- kontrola na rozdílná EM GUID u DB Instance
merge
 into OLI_OWNER.DBINSTANCES oli
USING (
    -- data z OEM
    select d.target_guid, d.instance_name
        from DASHBOARD.MGMT$DB_DBNINSTANCEINFO d
        JOIN DASHBOARD.MGMT$TARGET t ON d.target_guid = t.target_guid
        WHERE t.target_type = 'oracle_database'
          AND instance_name NOT IN (
            'dbfwdb', 'COGP2', 'BRJ', 'ISS', 'RETAD', 'CRMDB')
      ) oem
ON (upper(oli.inst_name) = upper(oem.instance_name))
when matched then
  update set oli.em_guid = oem.target_guid
;


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
  and (oem.host_name NOT like '%dbzal%' AND oem.host_name NOT like 'dbtest%') -- duplicate server name
  ) oem
ON (oem.hostname = oli.hostname)
when matched then
update set oli.em_guid = oem.target_guid;


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

