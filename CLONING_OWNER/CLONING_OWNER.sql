--
-- Orchestrace klonování
--

- přidat REST API pro GET a PUT metodu
- přidat pro GET možnost vypsat di parametry klonování

sqlplus -s / as sysdba @/dba/clone/sql/INFP_clone_params.sql RTOZA

-- update CLONE_SOURCE_LICDB_ID
update OLI_OWNER.DATABASES
  set CLONING_METHOD_ID = 3,   -- set to
      CLONE_SOURCE_LICDB_ID = (
      -- source db
      select licdb_id from OLI_OWNER.DATABASES where dbname = 'CRMPK')
  -- target db
  where dbname like 'CRMTA';


select licdb_id, dbname, rac, CLONE_SOURCE_LICDB_ID, CLONING_METHOD_ID
  FROM OLI_OWNER.DATABASES
  where dbname like 'MCI%'
  order by DBNAME;

-- zrusit CLONING_RELATION a nahradit za cloning_target_database
select * FROM CLONING_OWNER.CLONING_RELATION
  where target_dbname = 'BOSON';

select * FROM CLONING_OWNER.CLONING_TARGET_DATABASE
  where target_dbname = 'BOSON';

-- EXPORT/IMPORT
```
SCHEMA=CLONING_OWNER,CLONING_PY
OPTIONS=" directory=DATA_PUMP_DIR COMPRESSION=ALL EXCLUDE=STATISTICS METRICS=YES LOGTIME=ALL FLASHBACK_TIME=SYSTIMESTAMP "
expdp \'/ as sysdba\' schemas=$SCHEMA $OPTIONS dumpfile=cloning.dmp logfile=cloning_exp.log
--
impdp \'/ as sysdba\' DIRECTORY=DATA_PUMP_DIR dumpfile=cloning.dmp logfile=cloning_imp.log
```

-- drop user
--
-- drop user cloning_py cascade;
-- create user cloning_py identified by abcd1234 profile PROF_APPL;
-- grant execute on cloning_owner.cloning_api to cloning_py;
-- grant SELECT on CLONING_OWNER.CLONING_TASKS to CLONING_PY ;

```
drop user cloning_owner cascade;
create user cloning_owner identified by abcd1234 profile PROF_APPL
  default tablespace users quota unlimited on users ;

grant create view, create synonym to CLONING_OWNER;

grant SELECT,references on OLI_OWNER.DATABASES  to CLONING_OWNER;
grant update on OLI_OWNER.DATABASES to CLONING_OWNER;
grant SELECT on OLI_OWNER.SERVERS to CLONING_OWNER;
grant SELECT on OLI_OWNER.DBINSTANCES to CLONING_OWNER;
grant SELECT on OLI_OWNER.APP_DB to CLONING_OWNER;
grant SELECT on OLI_OWNER.APPLICATIONS to CLONING_OWNER;
-- DASHBOARD MGMT view
grant SELECT on DASHBOARD.MGMT$DB_DBNINSTANCEINFO to CLONING_OWNER;
grant SELECT on DASHBOARD.MGMT$DB_INIT_PARAMS to CLONING_OWNER;
grant SELECT on DASHBOARD.CM$MGMT_ASM_CLIENT_ECM to CLONING_OWNER;
```

select
  --*
  step_name
  from CLONING_OWNER.CLONING_METHOD_STEP
  where cloning_method_id = 3
order by position  ;

-- CLONNING PARAMS
asm_source_dg=${source_db}_D01
source_spfile=+JIRKA_DATA/JIRKA/spfilejirka.ora

source_spfile==+${asm_source_dg}/${source_db}/spfile${source_db}.ora


-- CLMZA > CLMDD
4252: CLMDD
source_spfile=+CLMZA_D01/CLMZA/spfile
asm_source_dg=CLMZA_D01

CLMD
295 init_params=cpu_count=4,memory_target=16G,pga_aggregate_target,sga_target
399 init_params=cpu_count=4,memory_target=16G,pga_aggregate_target,sga_target
321 init_params=cpu_count=4,memory_target=16G,pga_aggregate_target,sga_target

CLMT
init_params cpu_count=4,memory_target=17179869184,pga_aggregate_target,sga_target

init_params cpu_count=8,sga_target=10G,pga_aggregate_target=8G,memory_target

clone_opts=

-- init params - default RESET ponechán ve skriptu
init_params=large_pool_size,shared_pool_size,db_cache_size,sga_max_size,local_listener,remote_listener,db_recovery_file_dest,log_archive_dest_1

REM INSERTING into CLONING_PARAMETER
SET DEFINE OFF;
Insert into CLONING_PARAMETER values ('-999','pre_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','post_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','clone_opts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','init_params','Y','0',null,null);
Insert into CLONING_PARAMETER values ('3','snapshot_name','N','0',null,null);
Insert into CLONING_PARAMETER values ('3','recover_opts','N','0',null,'--noarchivelog');
Insert into CLONING_PARAMETER values ('3','asm_source_dg','Y','0',null,null);
Insert into CLONING_PARAMETER values ('3','source_spfile','Y','0',null,null);
--

REM INSERTING into CLONING_PARAM_VALUE
SET DEFINE OFF;
REM INSERTING into CLONING_PARAMETER
SET DEFINE OFF;
Insert into CLONING_PARAMETER values ('-999','pre_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','post_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','clone_opts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','recover_opts','Y','0',null,'--noarchivelog');
Insert into CLONING_PARAMETER values ('-999','init_params','Y','0',null,'cpu_count=4,memory_target=8G,pga_aggregate_target,sga_target');
Insert into CLONING_PARAMETER values ('-999','asm_source_dg','Y','0',null,'$\{source_db}_D01');
Insert into CLONING_PARAMETER values ('-999','source_spfile','Y','0',null,'+\${asm_source_dg}/\${source_db}/spfile$\{source_db}.ora');
Insert into CLONING_PARAMETER values ('-999','snapshot_name','Y','0',null,null);


-- upravy od Rasti ...
ALTER TABLE CLONING_OWNER.CLONING_METHOD_STEP  ADD (LOCAL VARCHAR2(1) DEFAULT 'N' NOT NULL);


