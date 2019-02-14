
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



dbms_resource_manager_privs.grant_switch_consumer_group('ADS_RETAIL_ETL_OWNER','APPL_USER_BATCH_GRP',FALSE);
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'ADS_RETAIL_ETL_OWNER','APPL_USER_BATCH_GRP');

dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DBSNMP','SYS_GROUP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'OUT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DWH_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'LIC_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'TEMP_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'INT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'AUDIT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'ETL_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'LOG_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'UTL_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DWA_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DWM_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'PRODUCT_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'REDIM_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CRIBIS_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CESS_FPV_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CESS_LISIFE_OWNER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'TUXCRM','APPL_ONLINE_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'REDIM_USER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DWH_RS_USER','EXT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'ODI_LIC_USER','APPL_USER_BATCH_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'A5035318','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10013','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10030','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10067','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10187','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10243','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10255','ANALYST_USER_GRP_1');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10360','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10380','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10492','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10611','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10925','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10943','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10946','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN10949','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11019','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11028','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11400','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11429','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11470','ANALYST_USER_GRP_1');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11530','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11680','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11740','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11954','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN11981','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12128','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12236','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12238','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12256','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12259','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'DLK_USER','EXT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12288','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12417','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12442','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12486','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12497','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12643','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12829','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN12859','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN13252','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN13430','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN13461','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN13508','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'COGNOS_SELF_CRRS','EXT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN13558','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'OWF_MGR','APPL_BATCH_RG');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN14209','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN14793','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN15105','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN18397','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN18613','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN20425','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN21368','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN21774','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN26492','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN26560','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN26961','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN26967','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27016','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27249','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27440','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27562','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27853','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN27890','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN28956','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29135','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29414','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29532','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29565','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29574','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29623','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN29904','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30127','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30193','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30265','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30301','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30374','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30405','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30651','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30670','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30671','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30702','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30785','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30802','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30846','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30864','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN30887','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31032','ANALYST_USER_GRP_1');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31036','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31079','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31083','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31337','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31470','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31561','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31641','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31653','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31721','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN31776','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32000','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32007','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32425','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32773','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32902','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN32985','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33006','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33007','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33211','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33362','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33503','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33565','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33586','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33732','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33822','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33935','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33956','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN33999','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34121','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34179','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34299','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34472','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34487','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34620','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34815','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34822','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34836','SUPPORT_RG');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34837','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34995','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN34998','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35085','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35107','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35132','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35163','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35362','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35562','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35581','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35628','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35704','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN35894','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN36426','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN36450','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN36674','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN36981','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37001','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37028','SUPPORT_USER_GRP');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37046','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37081','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37135','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37147','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37247','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37291','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37530','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37763','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37775','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN37795','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38075','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38106','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38116','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38392','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38629','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN38933','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN39035','SUPPORT_RG');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN39344','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN39513','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN39559','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN39668','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN60020','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61010','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61062','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61089','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61123','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61140','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61181','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61236','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61267','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61364','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61418','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61534','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61584','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61585','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61592','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61593','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61627','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61632','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61697','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61698','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61773','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61779','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61826','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61861','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61875','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61889','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61923','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61992','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN61994','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62018','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62094','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62284','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62285','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62305','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62370','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62392','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62528','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62649','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62677','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62745','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62748','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62759','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62761','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62777','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62814','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62897','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN62898','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63011','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63027','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63043','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63165','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63221','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63242','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63247','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63252','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63281','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63389','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63527','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63566','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63691','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63699','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63727','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN63770','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76235','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76305','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76475','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76665','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76698','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76702','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76733','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN76908','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN77292','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN77398','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN77792','SUPPORT_RG');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78026','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78344','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78390','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78453','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78611','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78781','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78942','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN78965','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79064','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79156','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79513','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79548','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79615','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79689','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79772','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79781','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79918','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN79965','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80006','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80041','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80158','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80160','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80271','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80333','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80430','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80433','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80475','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80535','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80550','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80569','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80571','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80768','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80790','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80907','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN80950','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81123','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81163','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81204','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81253','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81280','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81696','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN81791','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82063','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82103','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82128','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82271','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82429','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82535','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82735','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82738','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82753','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82755','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82762','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN82881','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83059','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83140','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83204','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83318','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83437','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83510','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83553','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83692','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83758','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83759','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83791','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83852','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83883','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN83908','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84071','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84179','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84208','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84257','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84417','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84420','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84462','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84491','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84575','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84676','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84769','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84849','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84900','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84905','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84949','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN84985','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85301','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85308','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85323','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85343','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85364','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85366','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85439','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85446','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85517','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85544','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85595','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85932','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN85936','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86014','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86113','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86121','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86199','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86240','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86274','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86427','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86448','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86484','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86562','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86593','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86594','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86657','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86714','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86736','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86789','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86818','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86826','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86964','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN86978','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87103','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87206','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87208','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87223','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87258','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87300','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87380','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87388','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87434','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87443','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87449','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87472','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87480','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87495','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87518','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87520','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87568','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87597','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87601','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87621','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87692','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87697','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87731','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87778','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87784','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87865','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87868','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87886','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN87908','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88041','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88045','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88069','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88195','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88203','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88228','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88232','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88258','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88285','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88299','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88325','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88396','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88407','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88410','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88427','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88430','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88511','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88531','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88540','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88546','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88606','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88655','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88707','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88708','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88712','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88750','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88831','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88835','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88849','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88862','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN88890','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89014','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89111','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89215','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89317','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89350','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89394','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89400','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89427','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89456','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89486','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89521','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89554','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89602','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89607','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89631','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89665','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89696','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89705','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89804','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89819','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89821','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89829','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89850','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89895','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89911','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89929','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89964','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89983','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CEN89997','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CST40151','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CST40152','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CST40586','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CST40587','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'CST41172','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90009','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90011','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90015','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90023','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90042','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90054','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90077','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90097','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90098','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90100','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90112','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90218','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90233','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90236','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90252','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90253','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90300','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90301','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90308','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90321','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90326','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90359','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90392','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90438','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90439','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT90725','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT91286','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT91306','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT92213','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT92842','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT93480','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT93490','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT93820','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT93828','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94077','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94173','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94393','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94586','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94703','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94722','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94785','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94797','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94881','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94952','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT94976','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95157','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95278','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95408','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95410','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95415','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95510','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95592','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95645','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95737','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95801','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95814','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95815','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95838','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95881','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT95975','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96008','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96065','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96224','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96235','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96243','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96300','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96345','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96382','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96427','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96800','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96803','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96836','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96877','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96931','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT96933','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97038','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97070','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97093','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97130','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97135','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97136','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97144','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97208','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97256','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97315','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97345','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97346','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97352','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97381','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97531','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97535','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97541','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97577','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97610','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97612','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97613','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97625','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97669','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97729','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97763','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97821','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97856','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97913','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97914','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97923','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97924','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97940','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97960','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97970','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT97989','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98043','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98081','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98128','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98129','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98139','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98174','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98178','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98199','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98200','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98201','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98233','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98240','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98275','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98277','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98281','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98352','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'EXT98354','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60014','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60033','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60081','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60082','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60090','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60106','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60125','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60179','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60201','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60210','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60237','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60253','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60256','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60265','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60297','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60385','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60412','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60414','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60415','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60416','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60417','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60420','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60422','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60610','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60784','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60786','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60789','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60800','ANALYST_USER_GRP_2');
dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SOL60851','ANALYST_USER_GRP_2');

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
