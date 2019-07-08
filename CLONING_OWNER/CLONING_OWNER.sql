--
-- Orchestrace klonování - clone app
--

- přidat REST API pro GET a PUT metodu
- přidat pro GET možnost vypsat di parametry klonování

sqlplus -s / as sysdba @/dba/clone/sql/INFP_clone_params.sql RTOZA


connect CLONING_OWNER/abcd1234

-- source target info
select *
  from oli_owner.databases
  where 1= 1
    -- and CLONING_METHOD_ID = 3  -- SNAPVX_CLONE
    AND dbname like 'BOSON'
--    and env_status = 'Pre-production'
;

-- pouzit method_group_name namistomethod_name !
select * FROM CLONING_OWNER.CLONING_TARGET_DATABASE
  where method_group_name like '%SNAP%'
    and method_name like 'RMAN%';

-- DWHT update na alias 1
UPDATE oli_owner.databases d
  set d.clone_source_licdb_id = NULL,
      d.clone_source_alias_id = 1
 where d.dbname like 'DWHT%';


-- source alias
SELECT * FROM source_alias;
SELECT * FROM source_alias_db;

-- CLONE_SOURCE_LICDB_ID - SnapVX
-- zmenit method_id
-- zmenit template_id
update OLI_OWNER.DATABASES
  set CLONING_METHOD_ID = NULL,   -- set to G800 method
      CLONE_SOURCE_LICDB_ID = (
      -- source db
      select licdb_id from OLI_OWNER.DATABASES where dbname = 'RDBPKA')
  -- target db
  where dbname like 'RDBTA%';

-- reset cloning_method_id
update OLI_OWNER.DATABASES
  set CLONING_METHOD_ID = NULL
  where dbname in ('CPSZA','SMARTZ','RECONZ','PWCZ')
  ;



-- clone source alias
update OLI_OWNER.DATABASES
  set CLONING_METHOD_ID = (
        select cloning_method_id from CLONING_METHOD where method_name = 'VSP_G800'),
      CLONE_SOURCE_LICDB_ID = NULL,
      clone_source_alias_id = (
          select source_alias_id from source_alias where alias_name = 'DWHSRC' )
  -- target db
  where dbname like 'DWHT%';


-- CLONING_METHOD
-- METHOD_GROUP

select * FROM CLONING_METHOD
  where 1 = 1
    --and allow_disk_snapshot = 'Y'
    -- and method_name like '%GI%'
    and method_type in ('C')   -- C / B / R / D
 order by method_name
;

GI_CREATE_ANSIBLE | GI:Create Golden Image to TSM using ansible

-- CLONING_METHOD_STEP

select * from CLONING_METHOD_STEP
  where cloning_method_id = 3
   order by position
;

--
insert into CLONING_METHOD_STEP values (3,'STEP330_dbms_stats.sh',330,'Purge and change dbms_stats retention','Y','N');


-- posun pozice
update CLONING_METHOD_STEP
  set step_name = 'STEP070_drop_db.sh',
      step_description ='Drop database',
      position = 70
 where position = 15;


-- INSERTING into CLONING_METHOD_STEP - common - local

insert into CLONING_METHOD_STEP values (9,'clone_create_golden_image.yml',100,'Create Golden Image','N','Y');

-- CLONING_PARAMETER

Insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','source_group','N',NULL,'Source device group',NULL, 'N');
insert into CLONING_OWNER.CLONING_PARAMETER  values ('C','ansible_playbook','N',NULL,'Ansible playbook file',NULL, 'N');


--
-- kde všude máme parametry
--

define parameter = cpu_count

select * FROM  cloning_parameter
  where lower(parameter_name) = '&parameter'
  order by lower(parameter_name);

select *
  from           template_param_value
    natural join cloning_template
  where parameter_name = '&parameter';

select * FROM db_param_value
  where parameter_name = '&parameter';

select dbname, parameter_name, parameter_value, env_status, cloning_method_id
   FROM db_param_value p
    natural join oli_owner.databases d
  where parameter_name = '&parameter'
     -- and env_status = 'Pre-production'
     -- and dbname like 'RMD%'
 order by dbname ;

-- ${source_db}_D01
/*
delete FROM db_param_value p
  where parameter_name = '&parameter'
    and licdb_id in (4362)
   and p.parameter_value = '${source_db}_DATA'
  ;
*/

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

