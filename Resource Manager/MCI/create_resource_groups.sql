/*
 * defince Resource Groups
 */

BEGIN
dbms_resource_manager.clear_pending_area();
dbms_resource_manager.create_pending_area();

dbms_resource_manager.create_consumer_group(consumer_group => 'CIC_RG', comment => 'CBL');
dbms_resource_manager.create_consumer_group(consumer_group => 'INETEXT_RG', comment => 'Internet');
dbms_resource_manager.create_consumer_group(consumer_group => 'INETINT_RG', comment => 'Intranet');
dbms_resource_manager.create_consumer_group(consumer_group => 'MCI_JOBS_RG', comment => 'Jobs');

dbms_resource_manager.submit_pending_area();
END;
/

/*
 * grantovani prepnuti PUBLIC
 */

begin
  DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP ('PUBLIC', 'CIC_RG', FALSE);
  DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP ('PUBLIC', 'INETEXT_RG', FALSE);
  DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP ('PUBLIC', 'INETINT_RG', FALSE);
  DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP ('PUBLIC', 'MCI_JOBS_RG', FALSE);
end;
/

/*
 * nastaveni mapovani RG
 */
	
BEGIN
dbms_resource_manager.clear_pending_area();
dbms_resource_manager.create_pending_area();
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.service_name,
    'CIC',
    'CIC_RG'
);
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.service_name,
    'CIC_DTP',
    'CIC_RG'
);
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.service_name,
    'INETEXT',
    'INETEXT_RG'
);
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.service_name,
    'INETINT',
    'INETINT_RG'
);
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.service_name,
    'MCI_JOBS',
    'MCI_JOBS_RG'
);
dbms_resource_manager.submit_pending_area();
END;
/

-- TOAD a PLSQLDev sniz prioritu
BEGIN
dbms_resource_manager.clear_pending_area();
dbms_resource_manager.create_pending_area();
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.client_program,
    'PLSQLDev.exe',
    'DEFAULT_CONSUMER_GROUP'
);
dbms_resource_manager.set_consumer_group_mapping(
    dbms_resource_manager.client_program,
    'TOAD.exe',
    'DEFAULT_CONSUMER_GROUP'
);
dbms_resource_manager.submit_pending_area();
END;
/