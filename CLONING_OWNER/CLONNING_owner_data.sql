--
-- SYNONYM
--
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."MGMT$DB_DBNINSTANCEINFO"
  FOR "DASHBOARD"."MGMT$DB_DBNINSTANCEINFO";
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."MGMT$DB_INIT_PARAMS"
  FOR "DASHBOARD"."MGMT$DB_INIT_PARAMS";
CREATE OR REPLACE SYNONYM "CLONING_OWNER"."CM$MGMT_ASM_CLIENT_ECM"
  FOR "DASHBOARD"."CM$MGMT_ASM_CLIENT_ECM";

--
-- VIEW
-- zrušit a nahradit za cloning_target_database
create or replace view cloning_owner.cloning_relation
AS
      SELECT
        s.dbname source_dbname,
        s.rac source_is_rac,
        t.dbname target_dbname,
        t.licdb_id target_id,
        t.rac target_is_rac,
        t.env_status target_env,
        m.method_name method
      FROM oli_owner.databases t
           -- poze db s definovanou vazbou
           JOIN oli_owner.databases s ON t.clone_source_licdb_id= s.licdb_id
           -- pouze db s definovanou cloning method
           JOIN cloning_owner.cloning_method m ON t.cloning_method_id    = m.cloning_method_id
      WHERE 1=1
;

-- granty zatím moc nefungují ...
grant select on oli_owner.databases to cloning_py with grant option;
grant select on cloning_owner.cloning_method to cloning_py with grant option;
grant select on cloning_owner.cloning_relation to cloning_py;
create synonym cloning_py.cloning_relation for cloning_owner.cloning_relation;

-- pipelined type - jde jen špatně přepsat vo selecktu ...

-- data
REM INSERTING into CLONING_METHOD
SET DEFINE OFF;
Insert into CLONING_METHOD values ('1','RMAN_DUPLICATE','Duplikace RMAN - do GUI','vykecavaci');
Insert into CLONING_METHOD values ('2','HITACHI','Pole HITACHI HUS VM metoda','vykecavaci');
Insert into CLONING_METHOD values ('3','SNAPVX','Pole VMAX3 přes SnapVX snapshoty','vykecavaci');
Insert into CLONING_METHOD values ('-999','COMMON','Obecna metoda pro obecne parametry','vykecavaci');


REM INSERTING into CLONING_METHOD_STEP
SET DEFINE OFF;
Insert into CLONING_METHOD_STEP values ('3','STEP001_prepare.sh','1','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP005_pre_sql_scripts.sh','5','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP010_shutdown_db.sh','10','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP020_umount_asm_dg.sh','20','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP100_create_disk_snapshot.sh','100','Desc','N','Y');
Insert into CLONING_METHOD_STEP values ('3','STEP109_mount_asm_dg.sh','109','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP110_recover_clone_db.sh','110','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP120_rename_clone_db.sh','120','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP130_rename_clone_asmdg.sh','130','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP140_password_file.sh','140','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP180_rac_drop_unused_redo_thread.sh','180','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP205_emcli_stop_blackout.sh','205','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP210_rman_reset_config.sh','210','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP220_rman_resync.sh','220','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP230_rman_backup_validate.sh','230','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP300_app_sql_scripts.sh','300','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP310_grant_dba.sh','310','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP320_autoextend_on.sh','320','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('3','STEP400_arm_audit.sh','400','Desc','Y','Y');
Insert into CLONING_METHOD_STEP values ('3','STEP410_send_email.sh','410','Desc','Y','Y');

-- Hitach HUS VM
Insert into CLONING_METHOD_STEP values ('2','STEP001_prepare.sh','1','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP005_pre_sql_scripts.sh','5','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP010_shutdown_db.sh','10','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP020_umount_asm_dg.sh','20','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP100_create_hitachi_clone.sh','100','Desc','N','N');
--
Insert into CLONING_METHOD_STEP values ('2','STEP105_change_asm_diskstring.sh','105','Desc','N','N');
--
Insert into CLONING_METHOD_STEP values ('2','STEP109_mount_asm_dg.sh','109','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP110_recover_clone_db.sh','110','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP120_rename_clone_db.sh','120','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP130_rename_clone_asmdg.sh','130','Desc','Y','N');
--
Insert into CLONING_METHOD_STEP values ('2','STEP135_default_asm_diskstring.sh','135','Desc','N','N');
--
Insert into CLONING_METHOD_STEP values ('2','STEP140_password_file.sh','140','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP180_rac_drop_unused_redo_thread.sh','180','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP205_emcli_stop_blackout.sh','205','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP210_rman_reset_config.sh','210','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP220_rman_resync.sh','220','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP230_rman_backup_validate.sh','230','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP300_app_sql_scripts.sh','300','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP310_grant_dba.sh','310','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP320_autoextend_on.sh','320','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('2','STEP400_arm_audit.sh','400','Desc','Y','Y');
Insert into CLONING_METHOD_STEP values ('2','STEP410_send_email.sh','410','Desc','Y','Y');



-- upravy od Rasti ...
ALTER TABLE CLONING_OWNER.CLONING_METHOD_STEP  ADD (LOCAL VARCHAR2(1) DEFAULT 'N' NOT NULL);


-- CLONING_PARAMETER
REM INSERTING into CLONING_PARAMETER
SET DEFINE OFF;
Insert into CLONING_PARAMETER values ('-999','app_supp_email','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','asm_source_dg','Y','0',null,'$\{source_db}_D01');
Insert into CLONING_PARAMETER values ('-999','clone_opts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','cpu_count','N','0',null,'4');
Insert into CLONING_PARAMETER values ('-999','memory_target','N','0',null,null);
Insert into CLONING_PARAMETER values ('-999','pga_aggregate_target','N','0',null,'8G');
Insert into CLONING_PARAMETER values ('-999','post_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','pre_sql_scripts','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','recover_opts','Y','0',null,'--noarchivelog');
Insert into CLONING_PARAMETER values ('-999','sga_target','N','0',null,'16G');
Insert into CLONING_PARAMETER values ('-999','snapshot_name','Y','0',null,null);
Insert into CLONING_PARAMETER values ('-999','source_spfile','Y','0',null,'+\${asm_source_dg}/\${source_db}/spfile$\{source_db}.ora');

