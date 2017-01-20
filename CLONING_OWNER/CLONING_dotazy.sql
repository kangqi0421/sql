--
-- Orchestrace klonování
--

-- update CLONE_SOURCE_LICDB_ID
update OLI_OWNER.DATABASES
  set CLONE_SOURCE_LICDB_ID = (
    -- source db
    select licdb_id from OLI_OWNER.DATABASES where dbname = 'RTOTP')
  -- target db
  where dbname like 'RTODP';

-- target_db, target hostname
SELECT
   'source_db='||s.dbname source_db,
   'target_db='||d.dbname target_db,
   --d.CLONE_SOURCE_LICDB_ID,
   d.CLONING_METHOD_ID,
   --env_status,
   --app_name,
   'target_hostname='||CONCAT(hostname, '.'||domain) server
FROM
  -- target db
  OLI_OWNER.DATABASES d
  -- source db
  join OLI_OWNER.DATABASES s ON (d.CLONE_SOURCE_LICDB_ID = s.licdb_id)
  join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
  JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  JOIN OLI_OWNER.SERVERS s ON (i.SERVER_ID = s.server_id)
 WHERE d.dbname
   in ('CLMTA')
ORDER BY APP_NAME;


-- spfile
SELECT
    distinct 'source_spfile='||VALUE
  FROM
    dashboard.mgmt$db_init_params p
    join OLI_OWNER.DATABASES d ON (d.dbname = REDIM_GET_SHORT_NAME(p.target_name))
    join OLI_OWNER.DATABASES s ON (s.CLONE_SOURCE_LICDB_ID = d.licdb_id)
  WHERE NAME like 'spfile'
    and s.dbname like 'CLMTA'
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


