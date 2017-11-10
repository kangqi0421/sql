--
-- Orchestrace klonování
--

- přidat REST API pro GET a PUT metodu
- přidat pro GET možnost vypsat di parametry klonování

sqlplus -s / as sysdba @/dba/clone/sql/INFP_clone_params.sql RTOZA


connect CLONING_OWNER/abcd1234

-- CLONE_SOURCE_LICDB_ID - SnapVX
-- zmenit method_id
-- zmenit template_id
update OLI_OWNER.DATABASES
  set CLONING_METHOD_ID = 2,   -- set to
      CLONING_TEMPLATE_ID = 3,
      CLONE_SOURCE_LICDB_ID = (
      -- source db
      select licdb_id from OLI_OWNER.DATABASES where dbname = 'RDBPKA')
  -- target db
  where dbname like 'RDBTA%';


select licdb_id, dbname, rac,
    CLONE_SOURCE_LICDB_ID, CLONING_METHOD_ID, CLONING_TEMPLATE_ID
  FROM OLI_OWNER.DATABASES
  where 1=1
    and dbname like 'RTO%'
    and cloning_method_id = 3
  order by DBNAME;

select * FROM CLONING_OWNER.CLONING_TARGET_DATABASE
  where target_dbname like 'RDBTA%';

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

GRANT execute on OLI_OWNER.UTILS to CLONING_OWNER;

select
  --*
  step_name
  from CLONING_OWNER.CLONING_METHOD_STEP
  where cloning_method_id = 3
order by position  ;

-- CLONNING PARAMS
asm_source_dg=${source_db}_D01
source_spfile=+JIRKA_DATA/JIRKA/spfilejirka.ora

source_spfile = +${asm_source_dg}/${source_db}/spfile${source_db}.ora

control_files = '+CRMPKTST_D01/CRMPKTST/CONTROLFILE/current.257.942405711'


-- CLMZA > CLMDD
4252: CLMDD
source_spfile=+CLMZA_D01/CLMZA/spfile
asm_source_dg=CLMZA_D01

clone_opts=

-- rozděleno na ARCHIVELOG a NOARCHIVELOG


--
-- SYNONYM
--
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."MGMT$DB_DBNINSTANCEINFO"
  FOR "DASHBOARD"."MGMT$DB_DBNINSTANCEINFO";
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."MGMT$DB_INIT_PARAMS"
  FOR "DASHBOARD"."MGMT$DB_INIT_PARAMS";
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."CM$MGMT_ASM_CLIENT_ECM"
  FOR "DASHBOARD"."CM$MGMT_ASM_CLIENT_ECM";


-- granty zatím moc nefungují ...
grant select on oli_owner.databases to cloning_py with grant option;
grant select on cloning_owner.cloning_method to cloning_py with grant option;
grant select on cloning_owner.cloning_relation to cloning_py;
create synonym cloning_py.cloning_relation for cloning_owner.cloning_relation;

-- pipelined type - jde jen špatně přepsat vo selecktu ...

-- data
REM INSERTING into CLONING_METHOD
SET DEFINE OFF;
Insert into CLONING_METHOD values ('7','GI_RESTORE','Golden Image restore from tape','Golden Image restore from tape', 'N');

update CLONING_METHOD_STEP
  set step_name = 'STEP070_drop_db.sh',
      step_description ='Drop database',
      position = 70
 where position = 15;

 update CLONING_METHOD_STEP
  set step_name = 'STEP001_prepare.sh',
      step_description ='Prepare faze klonovani',
      position = 10
 where position = 1;


-- STEP
Insert into CLONING_METHOD_STEP values (6,'STEP110_rman_duplicate_active.sh.sh',110,'RMAN duplicate from tape','N','N');

-- CLONING_PARAMETER
REM INSERTING into CLONING_PARAMETER
SET DEFINE OFF;
Insert into CLONING_PARAMETER  values ('C','until_time','N',NULL,'RMAN until time dd.mm.yyyy hh24:mi:ss','N');
Insert into CLONING_PARAMETER  values ('C','restore_password','N',NULL,'Restore Appl. hash passwords with granted role CS_APPL_ACCOUNTS',NULL, 'N');


Insert into CLONING_PARAMETER  values ('C','recover_opts','Y','0','Ponechat --noarchivelog pro vytvoření klonu. Pro změnu LOG_MODE se používá parametr ARCHIVELOG','--noarchivelog','N');
Insert into CLONING_PARAMETER  values ('I','memory_target','N','0',null,null,'Y');
Insert into CLONING_PARAMETER  values ('C','snapshot_name','Y','0',null,null,'N');
Insert into CLONING_PARAMETER  values ('C','pre_sql_scripts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER  values ('C','post_sql_scripts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER  values ('I','SHARED_POOL_SIZE','N',null,'minimalni hodnota pro shared pool',null,'N');
Insert into CLONING_PARAMETER  values ('C','ARCHIVELOG','Y','0','Vynucené přepnutí databáze do archivního režimu.','false','N');
Insert into CLONING_PARAMETER  values ('C','asm_source_dg','Y','0',null,'${source_db}_D01','N');
Insert into CLONING_PARAMETER  values ('C','source_spfile','Y','0','Umístění zdrojového spfile.','+${source_db}_D01/${source_db}/spfile${source_db}.ora','N');
Insert into CLONING_PARAMETER  values ('I','db_recovery_file_dest','N','0','Při ARCHIVELOG = true, default je <DBNAME>_FRA','${source_db}_FRA','N');
Insert into CLONING_PARAMETER  values ('I','db_recovery_file_dest_size','N','0','Při ARCHIVELOG = true, default je velikost FRA ASM diskgroupy',null,'N');
Insert into CLONING_PARAMETER  values ('C','app_supp_email','Y','0',null,'jsrba@csas.cz,jbohuslav@csas.cz','N');
Insert into CLONING_PARAMETER  values ('I','cpu_count','N','0',null,'4','N');
Insert into CLONING_PARAMETER  values ('I','pga_aggregate_target','N','0',null,'8G','N');
Insert into CLONING_PARAMETER  values ('I','sga_target','N','0',null,'16G','N');


REM INSERTING into CLONING_TEMPLATE
Insert into CLONING_TEMPLATE values ('1','MALA_DB');
Insert into CLONING_TEMPLATE values ('2','RTODS');
Insert into CLONING_TEMPLATE values ('3','RDBT');

REM INSERTING into TEMPLATE_PARAM_VALUE
SET DEFINE OFF;
Insert into TEMPLATE_PARAM_VALUE values ('1','I','memory_target',null,'Y');
Insert into TEMPLATE_PARAM_VALUE values ('1','I','cpu_count','4','N');
Insert into TEMPLATE_PARAM_VALUE values ('1','I','pga_aggregate_target','8G','N');
Insert into TEMPLATE_PARAM_VALUE values ('1','I','sga_target','16G','N');
Insert into TEMPLATE_PARAM_VALUE values ('3','I','memory_target',null,'Y');
Insert into TEMPLATE_PARAM_VALUE values ('3','I','cpu_count','4','N');
Insert into TEMPLATE_PARAM_VALUE values ('3','I','pga_aggregate_target','8G','N');
Insert into TEMPLATE_PARAM_VALUE values ('3','I','sga_target','16G','N');
Insert into TEMPLATE_PARAM_VALUE values ('3','C','app_supp_email','jsrba@csas.cz,zelis@csas.cz','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','I','sga_target','50G','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','I','memory_target',null,'Y');
Insert into TEMPLATE_PARAM_VALUE values ('2','I','pga_aggregate_target','24G','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','I','cpu_count','8','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','C','pre_sql_scripts','${CLONE_DIR}/sql/uloz_app_hesla.sql','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','C','post_sql_scripts','${TODAY_FMT}/${target_db}_nastav_hesla.sql','N');
Insert into TEMPLATE_PARAM_VALUE values ('2','C','app_supp_email','jsrba@csas.cz,rtods@csas.cz,fas-alfa@csas.cz','N');


REM INSERTING into METHOD_PARAM_VALUE
SET DEFINE OFF;
Insert into METHOD_PARAM_VALUE values ('3','I','db_block_checksum','FULL','N');
Insert into METHOD_PARAM_VALUE values ('3','C','recover_opts','--noarchivelog','N');
Insert into METHOD_PARAM_VALUE values ('2','I','db_block_checksum','FULL','N');
Insert into METHOD_PARAM_VALUE values ('2','C','recover_opts','--noarchivelog','N');
Insert into METHOD_PARAM_VALUE values ('2','C','asm_source_dg','${source_db}_D01','N');
Insert into METHOD_PARAM_VALUE values ('2','C','source_spfile','+${asm_source_dg}/${source_db}/spfile${source_db}.ora','N');
Insert into METHOD_PARAM_VALUE values ('3','C','asm_source_dg','${source_db}_D01','N');
Insert into METHOD_PARAM_VALUE values ('3','C','source_spfile','+${asm_source_dg}/${source_db}/spfile${source_db}.ora','N');


REM INSERTING into CLONING_METHOD_STEP
SET DEFINE OFF;
Insert into CLONING_METHOD_STEP values (6,'STEP010_prepare.sh',10,'Pre-klonovací skripty','Y','N');
Insert into CLONING_METHOD_STEP values (6,'STEP020_pre_sql_scripts.sh',20,'Pre-klonovací skripty','Y','N');
Insert into CLONING_METHOD_STEP values (6,'STEP040_rman_delete_backup.sh',40,'RMAN: delete force noprompt backup','Y','N');
Insert into CLONING_METHOD_STEP values (6,'STEP050_shutdown_db.sh',50,'Drop database','Y','N');
Insert into CLONING_METHOD_STEP values (6,'STEP070_drop_db.sh',70,'Drop database','Y','N');


REM INSERTING into CLONING_METHOD_STEP
SET DEFINE OFF;
Insert into CLONING_METHOD_STEP values (6, 'STEP115_srvctl_add_db.sh',115,'Přidání db do konfigurace Gridu','Y','N');

Insert into CLONING_METHOD_STEP values (6, 'STEP150_recreate_spfile_db.sh',150,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP160_archivelog_db.sh',160,'Přepnutí databáze mezi archivním a nearchivním režimem.','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP180_rac_drop_unused_redo_thread.sh',180,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP190_restart_db.sh',190,'Finální restart databaze pro overeni funkcnosti','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP205_emcli_stop_blackout.sh',206, 'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP210_rman_reset_config.sh',210,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP220_rman_resync.sh',220,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP300_app_sql_scripts.sh',300,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP310_grant_dba.sh',310,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP320_autoextend_on.sh',320,'Desc','Y','N');
Insert into CLONING_METHOD_STEP values (6, 'STEP400_arm_audit.sh',400,'Desc','Y','Y');
Insert into CLONING_METHOD_STEP values (6, 'STEP410_send_email.sh',410,'Desc','Y','Y');
