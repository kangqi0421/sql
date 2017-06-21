
-- DATABASES
SELECT dbname, env_status, app_name, hostname, domain
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE
--    dbname like 'RDBT%'
  s.domain like 'ack-prg.csin.cz'
--  a.app_name in ('SB')
--  and domain like 'cc.csin.cz'
--  group by app_name,hostname
ORDER BY APP_NAME  ;

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
-- INSERT db
--

MERGE
 into OLI_OWNER.DATABASES oli
USING
  (select dbname, em_guid, is_rac
     from  DASHBOARD.EM_DATABASE_INFO
    where dbname like 'COLT%'
  ) em
ON (oli.dbname = em.dbname)
  when matched then
    update set oli.em_guid = em.em_guid
  WHEN NOT MATCHED THEN
    INSERT (oli.DBNAME, oli.EM_GUID, oli.RAC)
    VALUES (em.dbname, em.em_guid, em.is_rac);
;

-- run job OEM_RESYNC_TO_OLI - syncne verze, status atd.
    dbms_scheduler.run_job('OLI_OWNER.OEM_RESYNC_TO_OLI', use_current_session => TRUE);

-- originál dotaz
INSERT INTO "OLI_OWNER". "DATABASES" ( "LICDB_ID", "DBNAME", "DBID", "ADMINISTRATOR", "DBVERSION", "RAC", "ENV_STATUS", "CA_ID", "EM_GUID", "EM_LAST_SYNC_DATE") VALUES (:B1 ,:B2 ,:B3 ,:B4 ,:B5 ,:B6 ,:B7 ,:B8 ,:B9 ,TO_DATE(:B10 , :B11 )) RETURNING ROWID, "LICDB_ID" INTO :O0 ,:O1

select * from OLI_OWNER.OMS_DBINSTANCES_MATCHING
  where instance_name like 'COLD%';

INSERT INTO DBINSTANCES(LICDB_ID,SERVER_ID,INST_NAME,INST_ROLE) SELECT :B1 ,MATCHED_SERVER_ID, SID,ROLE FROM OMS_DBINSTANCES_MATCHING WHERE INSTANCE_TARGET_GUID=:B4 AND DB_TARGET_GUID=:B3 AND MATCH_STATUS='U' AND (:B2 ,MATCHED_SERVER_ID,SID) NOT IN (SELECT LICDB_ID,SERVER_ID,INST_NAME FROM DBINSTANCES)
