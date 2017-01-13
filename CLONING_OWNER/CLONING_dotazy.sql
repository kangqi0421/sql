--
-- Orchestrace klonování
--

-- target_db, target hostname
SELECT -- dbname target_dbname,
   --CLONING_METHOD_ID, CLONE_SOURCE_LICDB_ID,
   --env_status,
   --app_name,
   'target_hostname='||CONCAT(hostname, '.'||domain) server
FROM
  OLI_OWNER.DATABASES d
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE d.dbname
   in ('RTOTP')
ORDER BY APP_NAME;

-- spfile
SELECT
    distinct 'source_spfile='||VALUE
  FROM
    dashboard.mgmt$db_init_params
  WHERE NAME like 'spfile'
    and TARGET_NAME like 'RTOZA%'
;

--
-- init parametry pro klonování
SELECT 'init_params='|| listagg(param,',') WITHIN GROUP (ORDER BY param)
FROM (
SELECT
    --TARGET_NAME,
    -- NAME,
    CASE upper(ISDEFAULT)
      WHEN 'FALSE' THEN name ||'='|| VALUE
      WHEN 'TRUE' then name
    END param
  FROM
    dashboard.mgmt$db_init_params
  WHERE TARGET_NAME like 'RTOTP'
    and NAME in ('memory_target','sga_target','pga_aggregate_target',
                 'cpu_count')
);

-- init parametry pro klonování ALL
SELECT
    TARGET_NAME,
    NAME,
    ISDEFAULT,
    value
  FROM
    dashboard.mgmt$db_init_params
  WHERE TARGET_NAME like 'RTOTP'
    and NAME in ('memory_target','sga_target','pga_aggregate_target',
                 'cpu_count')
;



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
Insert into CLONING_METHODS (CLONING_METHOD_ID,METHOD_NAME,METHOD_TITLE,DESCRIPTION) values ('4','GI_CREATE','Create Golden Image on SBT_TAPE',null);


