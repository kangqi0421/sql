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
Insert into CLONING_METHOD values ('1','RMAN_DUPLICATE','Duplikace RMAN - do GUI','vykecavaci');
Insert into CLONING_METHOD values ('2','HITACHI','Pole HITACHI HUS VM metoda','vykecavaci');
Insert into CLONING_METHOD values ('3','SNAPVX','Pole VMAX3 přes SnapVX snapshoty','vykecavaci');



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
Insert into CLONING_METHOD_STEP values ('3','STEP150_recreate_spfile_db.sh','150','Desc','Y','N');
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
Insert into CLONING_METHOD_STEP values ('2','STEP150_recreate_spfile_db.sh','150','Desc','Y','N');
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

-- DWH - pouze RECOVER a RENAME
Insert into CLONING_METHOD_STEP values ('4','STEP001_prepare.sh','1','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP005_pre_sql_scripts.sh','5','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP109_mount_asm_dg.sh','109','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP110_recover_clone_db.sh','110','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP120_rename_clone_db.sh','120','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP130_rename_clone_asmdg.sh','130','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP140_password_file.sh','140','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP150_recreate_spfile_db.sh','150','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP180_rac_drop_unused_redo_thread.sh','180','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP205_emcli_stop_blackout.sh','205','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP210_rman_reset_config.sh','210','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP220_rman_resync.sh','220','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP230_rman_backup_validate.sh','230','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP300_app_sql_scripts.sh','300','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP310_grant_dba.sh','310','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP320_autoextend_on.sh','320','Desc','Y','N');
Insert into CLONING_METHOD_STEP values ('4','STEP400_arm_audit.sh','400','Desc','Y','Y');
Insert into CLONING_METHOD_STEP values ('4','STEP410_send_email.sh','410','Desc','Y','Y');


-- CLONING_PARAMETER
REM INSERTING into CLONING_PARAMETER
SET DEFINE OFF;
Insert into CLONING_PARAMETER values ('C','app_supp_email','Y','0',null,'jsrba@csas.cz','N');
Insert into CLONING_PARAMETER values ('I','db_block_checksum','N','0',null,null,'N');
Insert into CLONING_PARAMETER values ('C','pre_sql_scripts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER values ('C','post_sql_scripts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER values ('C','clone_opts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER values ('C','recover_opts','Y','0',null,null,'N');
Insert into CLONING_PARAMETER values ('C','asm_source_dg','Y','0',null,'${source_db}_D01','N');
Insert into CLONING_PARAMETER values ('C','source_spfile','Y','0',null,'+${asm_source_dg}/${source_db}/spfile${source_db}.ora','N');
Insert into CLONING_PARAMETER values ('C','snapshot_name','Y','0',null,null,'N');
Insert into CLONING_PARAMETER values ('I','memory_target','N','0',null,null,'Y');
Insert into CLONING_PARAMETER values ('I','cpu_count','N','0',null,'4','N');
Insert into CLONING_PARAMETER values ('I','pga_aggregate_target','N','0',null,'8G','N');
Insert into CLONING_PARAMETER values ('I','sga_target','N','0',null,'16G','N');

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
