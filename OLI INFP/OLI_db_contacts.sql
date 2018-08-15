 -- OLI CONTACTS
 -- pouze dočasně, bude nahraženo přímo za kontakty v OLI


OLI_OWNER.CA_SRC_APPLICATIONS
- Z CA dostávám 3 kontakty – VA, SOM a AS + email
- chybí tam apl. administrátor a jeho zástupce, kdepak je najdu ?

select
--    *
    "as", "as_email", "serv_mode"
   from OLI_OWNER.CA_SRC_APPLICATIONS
  where resource_name like 'SAS_CPS';



-- DB per server, kontakty
SELECT hostname,
       a.app_name, d.dbname, 'DBO_'||d.dbname||'_'||d.licdb_id "qg0 CI",
       c.db_contact
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
  LEFT JOIN SRBA.DB_CONTACTS c ON (c.APP_NAME = a.APP_NAME)   -- pouze zaznamy, ktere maji kontakty
 WHERE s.hostname like '%ordb04'
--  and c.db_contact is NULL
ORDER BY hostname, d.dbname
;

-- APP_NAME,  EMAILS db_contacts
SELECT
  HOSTNAME,
  LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY HOSTNAME),
  -- remove duplicate values for contacts
  replace(regexp_replace(LISTAGG(db_contact,', ') WITHIN GROUP (ORDER BY HOSTNAME),'([^,]+)(,[ ]*\1)+'),',,',',')
FROM
(
SELECT distinct hostname, a.app_name, c.db_contact
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
  LEFT JOIN SRBA.DB_CONTACTS c ON (c.APP_NAME = a.APP_NAME)
 WHERE s.hostname in ('dordb04','tordb04')
  group by hostname, a.app_name, c.db_contact
)
GROUP BY HOSTNAME ORDER by 1;


create table REDIM_OWNER.DB_CONTACTS
(
  "APP_NAME" VARCHAR2(100) NOT NULL,
  "DB_CONTACT" VARCHAR2(320),
  CONSTRAINT "DB_CONTACTS_PK" PRIMARY KEY ("APP_NAME")
)
TABLESPACE "OLI_DATA";
alter user redim_owner quota unlimited on OLI_DATA;


 -- UPDATE CONTACTS
select * from SRBA.DB_CONTACTS
--  WHERE app_name like 'MAT'
  ORDER BY APP_NAME;

UPDATE SRBA.DB_CONTACTS
  set db_contact = 'Distribuce TEAM <fas-distribuce@csas.cz>'
  WHERE app_name in ('MW')
;
COMMIT;

-- insert app
insert into SRBA.DB_CONTACTS(app_id, app_name)
SELECT distinct o.app_id, APP_NAME
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
--  JOIN SRBA.DB_CONTACTS c ON (c.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE s.hostname like '%ordb%'
--  group by distinct hostname, app_name
order by APP_NAME
;

-- OEM OMSP

-- upravený REPORT na
select
target_name, host_name,
max( DECODE( property_name, 'orcl_gtp_contact', property_value, NULL ) ) "Contact",
max( DECODE( property_name, 'orcl_gtp_comment', property_value, NULL ) ) "Comment",
max( DECODE( property_name, 'orcl_gtp_line_of_bus', property_value, NULL ) ) "Line of Bussines",
max( DECODE( property_name, 'orcl_gtp_deployment_type', property_value, NULL ) ) "Deployment type",
max( DECODE( property_name, 'orcl_gtp_location', property_value, NULL ) ) "Location",
max( DECODE( property_name, 'udtp_2', property_value, NULL ) ) "Email"
from
(select p.target_name, t.host_name, p.property_value, p.property_name
from mgmt$target_properties p join SYSMAN.MGMT_TARGETS t on (p.TARGET_GUID = t.target_guid)
where p.target_type in ('rac_database','oracle_database')
)
group by target_name, host_name
order by upper(target_name);

-- Kontakty per Linux DB farma
select --p.*,
  --p.target_name, p.property_value "Contact"
  p.target_name||': '||p.property_value
 from mgmt$target_properties p
where 1=1
  and p.target_type in ('rac_database','oracle_database')
  and p.property_name = 'orcl_gtp_contact'  -- Contact
  --and property_name = 'orcl_gtp_lifecycle_status' -- Lifecycle status
  -- and property_name = 'OracleHome'  -- OracleHome
  and p.target_guid in (
  SELECT TARGET_GUID
    FROM MGMT_TARGETS
    WHERE target_type LIKE '%database'
      AND host_name LIKE 'tordb03.vs.csin.cz'
  )
order by upper(p.target_name);

*/