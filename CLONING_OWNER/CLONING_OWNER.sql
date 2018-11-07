--
-- Orchestrace klonování
--

- přidat REST API pro GET a PUT metodu
- přidat pro GET možnost vypsat di parametry klonování

sqlplus -s / as sysdba @/dba/clone/sql/INFP_clone_params.sql RTOZA


connect CLONING_OWNER/abcd1234

-- INFTA sequence - posun pro KLON id za 100k
ALTER SEQUENCE CLONING_TASK_TASK_ID_SEQ INCREMENT BY 100000;
SELECT CLONING_TASK_TASK_ID_SEQ.NEXTVAL FROM dual;
ALTER SEQUENCE CLONING_TASK_TASK_ID_SEQ INCREMENT BY 1;

-- source target info
select licdb_id, dbname, clone_source_licdb_id,
       clone_source_alias_id, CLONING_METHOD_ID
  from oli_owner.databases
  where dbname like 'CRM%';

select * FROM CLONING_OWNER.CLONING_TARGET_DATABASE
  where target_dbname like 'DWHTA2';

-- DWHT update na alias 1
UPDATE oli_owner.databases d
  set d.clone_source_licdb_id = NULL,
      d.clone_source_alias_id = 1
 where d.dbname like 'DWHT%';

-- update produkce pro umozneni klonu na SNAPVX_SNAPSHOT
UPDATE oli_owner.databases
  set CLONING_METHOD_ID = 16,
    CLONE_SOURCE_LICDB_ID = 317   -- DUMMY DB
 where dbname like 'SMARTP';

'SDPO','TS0O','TS3O','TS7O','TS9O'

-- source alias
SELECT * FROM source_alias;
SELECT * FROM source_alias_db;

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
-- password reuse
alter user cloning_owner profile default;
alter user cloning_owner identified by abcd1234;
alter user cloning_owner profile PROF_APPL;

grant cs_appl_accounts to cloning_owner;


grant create view, create synonym to CLONING_OWNER;

grant ALL on OLI_OWNER.DATABASES  to CLONING_OWNER;
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

grant all on CLONING_OWNER.DB_PARAM_VALUE to OLI_OWNER;

GRANT execute on OLI_OWNER.UTILS to CLONING_OWNER;

select
  --*
  step_name
  from CLONING_OWNER.CLONING_METHOD_STEP
  where cloning_method_id = 3
order by position  ;


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


-- data CLONING_METHOD
insert into CLONING_METHOD values ('16','SNAPVX_CLONE','SnapVX create disk snapshot'  ,'SnapVX create disk snapshot', 'Y', 'N');

insert into CLONING_METHOD_STEP values (16,'STEP100_create_snapshot.sh',100,'SnapVX create disk snapshot','N','Y');

update CLONING_METHOD_STEP
  set step_name = 'STEP070_drop_db.sh',
      step_description ='Drop database',
      position = 70
 where position = 15;

go to cab: if (nikki namisto maja) and (nikki ma derovany tricko)

n = rand()
if n == 24 then zajdu na cab

-- INSERTING into CLONING_METHOD_STEP - common / local (oem)

insert into CLONING_METHOD_STEP values (9,'STEP100_ansible_G800_disk_snapshot.sh',100,'Create disk SnapVX snapshot','N','Y');

insert into CLONING_METHOD_STEP values
  (2,'STEP102_shutdown_cascade_snapshot.sh',102,'Shutdown HUS VM thin databases','N','Y');
insert into CLONING_METHOD_STEP values
  (2,'STEP105_create_hitachi_clone.sh',105,'Create HUS VM thin snapshot','N','N');
insert into CLONING_METHOD_STEP values
  (2,'STEP106_split_cascade_snapshot.sh',106,'Pairsplit HUS VM thin snapshot','N','Y');
insert into CLONING_METHOD_STEP values
  (2,'STEP107_change_asm_diskstring.sh',107,'Change asm disktring localne pro vice Thin db snapshot','N','N');

Insert into CLONING_METHOD_STEP values (7,'STEP305_restore_appl_passwords.sh',305,'Restore původních aplikačních hesel označených rolí CS_APPL_ACOUNTS','Y','N');

-- CLONING_PARAMETER

select * from CLONING_PARAMETER
  order by lower(parameter_name);

REM INSERTING into CLONING_PARAMETER
Insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','source_group','N',NULL,'Source device group',NULL, 'N');
Insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','target_group','N',NULL,'Target device group',NULL, 'N');

insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','ansible_playbook','N',NULL,'Ansible playbook file',NULL, 'N');
insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','ansible_playbook','N',NULL,'Ansible playbook file',NULL, 'N');


--
-- kde všude máme parametry
--

define parameter = app_supp_email

select * FROM  cloning_parameter
  where parameter_name = '&parameter';

select *  from template_param_value
  where parameter_name = '&parameter';

select * FROM db_param_value
  where parameter_name = '&parameter';

SELECT p . parameter_type ,
       p . parameter_name ,
       p . mandatory ,
       tp . template_id,
       CASE
         WHEN dp . parameter_type IS NOT NULL THEN dp . parameter_value
         WHEN tp . parameter_type IS NOT NULL THEN tp . parameter_value
         WHEN mp . parameter_type IS NOT NULL THEN mp . parameter_value
         ELSE p . default_value
       END
     parameter_value ,
       CASE
         WHEN dp . parameter_type IS NOT NULL THEN dp . reset
         WHEN tp . parameter_type IS NOT NULL THEN tp . reset
         WHEN mp . parameter_type IS NOT NULL THEN mp . reset
         ELSE p . reset
       END
     reset ,
       CASE
         WHEN dp . parameter_type IS NOT NULL THEN 'TARGET_PARAMETER'
         WHEN tp . parameter_type IS NOT NULL THEN 'TEMPLATE_DEFAULT'
         WHEN mp . parameter_type IS NOT NULL THEN 'METHOD_DEFAULT'
         ELSE 'OVERALL_DEFAULT'
       END
     status
FROM cloning_parameter p ,
     db_param_value dp ,
     template_param_value tp ,
     method_param_value mp
WHERE 1 = 1
      AND dp . licdb_id in (
        select licdb_id from oli_owner.databases
        where dbname = 'BOSON')
      AND p.parameter_name = 'app_supp_email'
--      AND tp . template_id ( + ) = l_cloning_template_id
--      AND mp . method_id ( + ) = l_cloning_method_id
      AND p . parameter_type = dp . parameter_type ( + )
      AND p . parameter_name = dp . parameter_name ( + )
      AND p . parameter_type = tp . parameter_type ( + )
      AND p . parameter_name = tp . parameter_name ( + )
      AND p . parameter_type = mp . parameter_type ( + )
      AND p . parameter_name = mp . parameter_name ( + )
ORDER BY p . parameter_type ,  p . parameter_name
;

-- CONFIG_DATA
-- CLONING_REST_URL
-- ENV_NAME: PRODUCTION
select * FROM CONFIG_DATA;




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

-- SnapVX Restore
REM INSERTING into CLONING_METHOD_STEP
SET DEFINE OFF;
Insert into CLONING_METHOD_STEP values ('8','STEP010_prepare.sh','10','Pre-klonovací skripty','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP020_pre_sql_scripts.sh','20','Pre-klonovací skripty','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP050_shutdown_db.sh','50','Drop database','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP080_umount_asm_dg.sh','80','Umount s force ASM diskgroup','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP100_restore_snapshot.sh','100','SnapVX restore sg from snapshot','N','Y');
Insert into CLONING_METHOD_STEP values ('8','STEP109_mount_asm_dg.sh','109','Mount ASM DG','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP190_restart_db.sh','190','Finální restart databaze pro overeni funkcnosti','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP205_emcli_stop_blackout.sh','205','EM agent stop blackout','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP220_rman_resync.sh','220','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP300_app_sql_scripts.sh','300','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP305_restore_appl_passwords.sh','305','Restore původních aplikačních hesel označených rolí CS_APPL_ACOUNTS','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP310_grant_dba.sh','310','Grant DBA','Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP320_autoextend_on.sh','320',NULL,'Y','N');
Insert into CLONING_METHOD_STEP values ('8','STEP400_arm_audit.sh','400',NULL,'Y','Y');

