
define dbname = 'SYMP'

-- DATABASES
SELECT 
   --distinct app_name
    dbname, env_status, app_name, 
    NVL2(DOMAIN, HOSTNAME||'.'||DOMAIN, HOSTNAME) hostname
   --, domain
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE 1 = 1
--   and env_status = 'Production'
    AND dbname like 'TS2%'
    -- Pouze VMWare ORACLE-02-ANT
--    and s.lic_env_id = 3292
--  s.domain like 'ack-prg.csin.cz'
--    and hostname like 'dp%'
--  a.app_name in ('SB')
--  and domain like 'cc.csin.cz'
--  group by app_name,hostname
ORDER BY APP_NAME;

--

-- server per APP
SELECT DBNAME, hostname, app_name
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE
  REGEXP_LIKE(hostname, 'z?(p)ordb[[:digit:]]+')
  --s.hostname like 'tordb03'
  --a.app_name in ('SB')
  --and domain like 'cc.csin.cz'
  --group by app_name,hostname
ORDER BY hostname, dbname  ;


-- APP_NAME info data
SELECT HOSTNAME||': '|| LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY HOSTNAME)
FROM
(
-- innner join to remove duplicate values
SELECT hostname, app_name
      -- ,DBNAME
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE s.hostname like 'tordb03'
  group by hostname, app_name, dbname
)
GROUP BY HOSTNAME ORDER by 1;

-- OLAPI_DATABASES
SELECT HOSTNAME||': '|| LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY HOSTNAME)  from (
SELECT
  APP_NAME,
  DBNAME,
  INST_NAME,
  RAC,
  HOSTNAME, DOMAIN,
  s.FAILOVER_SERVER_ID
FROM
  OLI_OWNER.OLAPI_APPLICATIONS a
     JOIN OLI_OWNER.OLAPI_APP_DB o ON (A.APP_ID = o.APP_ID)
     JOIN OLI_OWNER.OLAPI_DATABASES d ON (o.licdb_id = d.licdb_id)
     JOIN OLI_OWNER.OLAPI_DBINSTANCES i ON (d.licdb_id = i.licdb_id)
     JOIN OLI_OWNER.OLAPI_SERVERS s ON (i.SERVER_ID = s.server_id)
WHERE
  --DBNAME in ('BRAP')
  hostname like 'tordb03'
--  hostname in ('pordb03', 'pordb04')
ORDER BY APP_NAME
) GROUP BY HOSTNAME ORDER BY 1;
;

-- update ENV status
update OLI_OWNER.DATABASES d
  set d.env_status = 'Test'
  where dbname like 'RDBT%';


--
-- delete
--

select 'call OLI_API.delete_database('|| DBMS_ASSERT.enquote_literal(d.dbname) ||');' as cmd
  from OLI_OWNER.DATABASES d
 where d.dbname like 'TS2%';
 
    select licdb_id 
       from databases
       where upper(dbname)=upper('TS2O'); 
       
delete from dbinstances where licdb_id=91;       
delete from databases where licdb_id = 91;

select * from   OLI_OWNER.APP_DB
  where app_id=80;  
--
-- INSERT do DATABASES
--

-- nahradit MERGE za OMS_DATABASES_MATCHING s match status na U
--
INSERT INTO OLI_OWNER.DATABASES (DBNAME, RAC, ENV_STATUS, DBVERSION, EM_GUID)
select DB_NAME,
       decode(dbracopt, 'YES', 'Y', 'N'),
       envstatus,
       dbversion,
       db_target_guid
  from OLI_OWNER.OMS_DATABASES_MATCHING
 WHERE match_status in ('U')
   and db_name like '&dbname'
;
--

MERGE
 into OLI_OWNER.DATABASES oli
USING
  (select dbname, em_guid, is_rac
     from  DASHBOARD.EM_DATABASE
    where dbname like '&dbname'
  ) em
ON (oli.dbname = em.dbname)
  when matched then
    update set oli.em_guid = em.em_guid
  WHEN NOT MATCHED THEN
    INSERT (oli.DBNAME, oli.EM_GUID, oli.RAC)
    VALUES (em.dbname, em.em_guid, em.is_rac);
;

-- run job OEM_RESYNC_TO_OLI - syncne verze, status atd.
exec  dbms_scheduler.run_job('OLI_OWNER.OEM_RESYNC_TO_OLI', use_current_session => TRUE);

-- INSERT do DBINSTANCES
select * from OLI_OWNER.OMS_DBINSTANCES_MATCHING
  where db_name like '&dbname';

INSERT INTO OLI_OWNER.DBINSTANCES (LICDB_ID, SERVER_ID, INST_NAME, EM_GUID)
SELECT
  matched_licdb_id,
  matched_server_id,
  instance_name,
  INSTANCE_TARGET_GUID
  from OLI_OWNER.OMS_DBINSTANCES_MATCHING
  where match_status in ('U')
    AND db_name like '&dbname'
;

--
-- SAS_APP
--

-- vložení záznamů z CA_APPLICATIONS do APPLICATIONS
MERGE
 into OLI_OWNER.APPLICATIONS d
USING
   (select cmdb_ci_id, APP_NAME, APP_LONG_NAME from OLI_OWNER.CA_APPLICATIONS
      where APP_NAME = 'ORDBF'
        and status = 'Alive'
    ) s
ON (s.app_name = d.app_name)
  WHEN NOT MATCHED THEN
    INSERT (d.ca_id, d.app_name, d.app_long_name)
    VALUES (s.cmdb_ci_id, s.APP_NAME, s.APP_LONG_NAME);
;

-- chybí ještě insert do OLI_OWNER.APP_DB
select *
FROM
  OLI_OWNER.DATABASES d
    join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
    JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
    JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  where d.dbname like 'CPTDA'
--  licdb_id = 6367
;

MERGE
 into OLI_OWNER.APP_DB d
USING
   (select d.licdb_id, a.app_id
    FROM
      OLI_OWNER.DATABASES d, OLI_OWNER.APPLICATIONS a
        where d.dbname   like 'CPTDA'
          and a.app_name like 'CPT'
    ) s
ON (s.licdb_id = d.licdb_id AND s.app_id = d.app_id)
  WHEN NOT MATCHED THEN
    INSERT (d.licdb_id, d.app_id)
    VALUES (s.licdb_id, s.app_id);
;


--
-- API delete databaze
--

define db=DLKTA

-- delete db instance pro migrace
DELETE from OLI_OWNER.DBINSTANCES
  WHERE licdb_id IN (
    SELECT distinct(i.licdb_id)
    FROM
      OLI_OWNER.DATABASES d
      JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
    WHERE dbname = '&DLKTA'
);

--
BEGIN
  for rec in (
    select licdb_id from OLI_OWNER.DATABASES
      where dbname = '&db')
  LOOP
    DELETE from OLI_OWNER.APP_DB where licdb_id = rec.licdb_id;
    DELETE from OLI_OWNER.DBINSTANCES where licdb_id = rec.licdb_id;
    DELETE from OLI_OWNER.DATABASES where licdb_id = rec.licdb_id;
  END LOOP;
END;
/

-- OLI konfigurace

select * FROM config_data;
LIC_CAPTURE_USAGE_TIMEOUT : default(365)