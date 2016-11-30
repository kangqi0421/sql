
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