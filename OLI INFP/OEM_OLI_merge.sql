-- DB version update
-- Lifecycle ENV_STATUS update
Poznámky:
- REDIM_GET_SHORT_NAME je funkce, která se z targetu typu COGT_pro_Honzu.nepouzivat snaží vytvořit DBNAME ;-)
- MAX je tam z důvodu duplicitních targetů na straně OEM i OLI

merge
 into OLI_OWNER.DATABASES oli
USING (
-- data z OEM
    SELECT REDIM_GET_SHORT_NAME(ver.target_name) DBNAME,
           max(ver.property_value) DBVERSION,
           max(env.property_value) ENV_STATUS
    FROM DASHBOARD.MGMT$TARGET_PROPERTIES ver
      JOIN DASHBOARD.MGMT$TARGET_PROPERTIES env ON (ver.TARGET_GUID=env.TARGET_GUID)
     WHERE ver.target_type IN ('oracle_database','rac_database')
      AND ver.property_name = 'Version'
      AND env.property_name = 'orcl_gtp_lifecycle_status'
     GROUP BY REDIM_GET_SHORT_NAME(ver.target_name)
      ) oem
ON (oem.dbname = oli.dbname)
when matched then
  update set oli.DBVERSION = oem.DBVERSION,
             oli.ENV_STATUS = oem.ENV_STATUS
;


-- kontrola na rozdílné GUID
-- dale se v podstate nepouziva
select oli.dbname, oem.target_guid, oli.em_guid, target_type, oem.TYPE_QUALIFIER3
  from OLI_OWNER.databases oli, DASHBOARD.MGMT$TARGET oem
where oli.dbname = REDIM_OWNER.REDIM_GET_SHORT_NAME(oem.target_name)
  and TYPE_QUALIFIER3 = 'DB'    -- mimo RAC
  and oli.em_guid <> oem.target_guid
order by 1;

-- merge DB guid from OEM -> OLI
-- uz neni potreba pro REDIM
merge
 into OLI_OWNER.DATABASES oli
USING
  (SELECT REDIM_GET_SHORT_NAME(target_name) target_name,
          target_guid
FROM
  DASHBOARD.MGMT$TARGET oem
WHERE 1=1
  AND oem.TYPE_QUALIFIER3 = 'DB'
  AND target_type <> 'rac_database'
  -- pouze u těch targetů, kde je rozdílné GUID
  and target_name in (
  'AFSDB','AFSDC','AFSP','AFSZA','APPA','APPB','BMWDA','BMWDB','BRJ','CAEPA','CAEPB','CAIPA','CMTP','CMTZA','COGP','COLZ','DLKP','DLKPDATA','DLKZA','DLKZDATA','DMTA1','DMTSP','DWHTA1','DWHTSP','EPAKUAT1','EPAKUAT2','FMWDA','FMWDB','FMWZA','INEINT','INEINTB','INEP','INEPRS','INEZ','KNXP','MCIP','MCITINT','MCITPRS','MCIZ','MCMEP','MCMIP','MEPTA','MEPTB','ODIP','ODIZA','ODSDDP','ODSTA1','ODSTA2','ODSTA3','ODSTSP','OERP','PARDE','PARDEDU','PARDINT','PARDPRS','PARDSYS','RDLP','RDLPT','RDSDA','RDSP','RDSTA','REPD2','SEAPT','SEATA','SEOTA','SKMP','TS0B','TS3B','TS3I','TS3O','VSDPB','VSDTA','VSDTB','WBLINT','WBLP','WBLPRS','WBLZ','WCMDA','WCMEA','WCMP','WCMP','WCMZA'
  )
  ) oem
ON (oem.target_name = oli.DBNAME)
when matched then
update set oli.em_guid = oem.target_guid;



-- merge server guid from OEM -> OLI
-- pro redim uz neni potreba
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


