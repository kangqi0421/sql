BEGIN
dbms_resource_manager.clear_pending_area();
dbms_resource_manager.create_pending_area();
dbms_resource_manager.set_consumer_group_mapping_pri(
    EXPLICIT => 1,
    CLIENT_PROGRAM => 2,
    SERVICE_MODULE_ACTION => 3,
    SERVICE_MODULE => 4,
    MODULE_NAME_ACTION => 5,
    MODULE_NAME => 6,
    SERVICE_NAME => 7,
    ORACLE_USER => 8,
    CLIENT_OS_USER => 9,
    CLIENT_MACHINE => 10
);
dbms_resource_manager.submit_pending_area();
END;
/
