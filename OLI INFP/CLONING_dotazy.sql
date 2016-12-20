--
-- Orchestrace klonování
--

# Tasky
- STEP001.sh - rozšířit o možnost popisu skriptu
- STEP001 - jak se skritepm, který se pouští lokálně z oem/boem ?
- cloning_owner
  - granty nad
grant select on OLI_OWNER.APP_DB  to CLONING_OWNER;
grant select on OLI_OWNER.APPLICATIONS  to CLONING_OWNER;

--
-- BOSON > JIRKA
SELECT dbname, CLONING_METHOD_ID, CLONE_SOURCE_LICDB_ID,
   env_status, app_name,
   CONCAT(hostname, '.'||domain) server
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE d.dbname in ('JIRKA', 'BOSON')
ORDER BY APP_NAME  ;



-- drop user
--
-- drop user cloning_owner cascade;
-- drop user cloning_py cascade;

create user cloning_owner identified by abcd1234 profile PROF_APPL default tablespace users quota unlimited on users ;
create user cloning_py identified by abcd1234 profile PROF_APPL;

-- cloning methods
REM INSERTING into CLONING_METHODS
Insert into CLONING_METHODS (CLONING_METHOD_ID,METHOD_NAME,METHOD_TITLE,DESCRIPTION) values ('1','RMAN_DUPLICATE','Duplikace RMAN - do GUI',null);
Insert into CLONING_METHODS (CLONING_METHOD_ID,METHOD_NAME,METHOD_TITLE,DESCRIPTION) values ('2','HUSVM','Pole HITACHI snapshot metoda',null);
Insert into CLONING_METHODS (CLONING_METHOD_ID,METHOD_NAME,METHOD_TITLE,DESCRIPTION) values ('3','VMAX3_SNAPVX','Pole VMAX3 se snapshoty SnapVX',null);


