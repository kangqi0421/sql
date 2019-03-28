
begin
  sys.dbms_resource_manager.clear_pending_area();
  sys.dbms_resource_manager.create_pending_area();

  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('ANALYST_RG','Analyst users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('ANALYST_USER_GRP_1','Analyst users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('ANALYST_USER_GRP_2','Analyst users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('APPL_BATCH_RG','Application batch users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('APPL_ONLINE_GRP','Message processing');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('APPL_ONLINE_RG','Application online users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('APPL_USER_BATCH_GRP','Daily loads group');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('EXT_USER_GRP','External users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('SUPPORT_RG','Support users');
  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('SUPPORT_USER_GRP','Service/application support');

  sys.dbms_resource_manager.submit_pending_area();

END;
/

-- consumer group mapping
begin
  sys.dbms_resource_manager.clear_pending_area();
  sys.dbms_resource_manager.create_pending_area();
  dbms_resource_manager.set_consumer_group_mapping(
      dbms_resource_manager.CLIENT_PROGRAM, 'TOAD.EXE', 'ANALYST_RG');
  dbms_resource_manager.set_consumer_group_mapping(
      dbms_resource_manager.CLIENT_PROGRAM, 'HTTPD@DWHPO1 (TNS V1-V3)', 'SUPPORT_RG');
  dbms_resource_manager.set_consumer_group_mapping(
      dbms_resource_manager.CLIENT_PROGRAM, 'HTTPD@DWHPO2 (TNS V1-V3)', 'SUPPORT_RG');
  sys.dbms_resource_manager.submit_pending_area();

END;
/

begin
  sys.dbms_resource_manager.clear_pending_area();
  sys.dbms_resource_manager.create_pending_area();

dbms_resource_manager_privs.grant_switch_consumer_group('SOL60210','ANALYST_USER_GRP_2',FALSE);
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60210',NULL);

end;
/


begin
  sys.dbms_resource_manager.clear_pending_area();
  sys.dbms_resource_manager.create_pending_area();

dbms_resource_manager_privs.grant_switch_consumer_group('ADS_RETAIL_ETL_OWNER','APPL_USER_BATCH_GRP',FALSE);
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'ADS_RETAIL_ETL_OWNER','APPL_USER_BATCH_GRP');


dbms_resource_manager_privs.grant_switch_consumer_group('SOL60210','ANALYST_USER_GRP_2',FALSE);
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60210','ANALYST_USER_GRP_2');


dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DBSNMP','SYS_GROUP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'OUT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DWH_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'LIC_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'TEMP_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'INT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'AUDIT_OWNER','APPL_USER_BATCH_GRP');

dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60417','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60420','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60422','ANALYST_USER_GRP_2');
...


  sys.dbms_resource_manager.submit_pending_area();

END;
/


BEGIN
    DBMS_RESOURCE_MANAGER.CLEAR_PENDING_AREA();
    DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
    DBMS_RESOURCE_MANAGER.CREATE_PLAN(
        PLAN => 'ODS_PLAN_PROD',
        COMMENT => 'DWH application plan.',
        MGMT_MTH => 'EMPHASIS');
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'APPL_ONLINE_GRP',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 90,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 0,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 8,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'EXT_USER_GRP',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 50,
        MGMT_P5 => 0,
        MGMT_P6 => 0,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 1,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'OTHER_GROUPS',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 0,
        MGMT_P7 => 90,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 1,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'ANALYST_USER_GRP_1',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 40,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 1,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'SYS_GROUP',
        COMMENT => '',
        MGMT_P1 => 40,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 0,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 4,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'APPL_USER_BATCH_GRP',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 60,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 0,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 8,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'ANALYST_USER_GRP_2',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 0,
        MGMT_P6 => 20,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 1,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(
        PLAN => 'ODS_PLAN_PROD',
        GROUP_OR_SUBPLAN => 'SUPPORT_USER_GRP',
        COMMENT => '',
        MGMT_P1 => 0,
        MGMT_P2 => 0,
        MGMT_P3 => 0,
        MGMT_P4 => 0,
        MGMT_P5 => 40,
        MGMT_P6 => 0,
        MGMT_P7 => 0,
        MGMT_P8 => 0,
        ACTIVE_SESS_POOL_P1 => NULL,
        QUEUEING_P1 => NULL,
        PARALLEL_DEGREE_LIMIT_P1 => 2,
        SWITCH_GROUP => '',
        SWITCH_TIME => NULL,
        MAX_EST_EXEC_TIME => NULL,
        UNDO_POOL => NULL,
        MAX_IDLE_TIME => NULL,
        MAX_IDLE_BLOCKER_TIME => NULL,
        SWITCH_IO_MEGABYTES => NULL,
        SWITCH_IO_REQS => NULL);
    DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/
