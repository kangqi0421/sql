-- tnsnames connect string --
  SELECT    
         sid.property_value||'='
		 || '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST='
         || HOST.property_value
         || ')(PORT='
         || port.property_value
         || ')))(CONNECT_DATA=(SID='
         || sid.property_value
         || ')(SERVER=DEDICATED)))'
            tns
    FROM mgmt_targets tn,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'MachineName') HOST,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'Port') port,
         (SELECT target_guid, property_value
            FROM mgmt_target_properties
           WHERE property_name = 'SID') sid
   WHERE     tn.target_guid = HOST.target_guid
         AND tn.target_guid = port.target_guid
         AND tn.target_guid = sid.target_guid
         AND tn.target_type IN ('oracle_database', 'rac_database')
         AND tn.category_prop_3 = 'DB'
         --AND tn.target_guid IN (SELECT TARGET_GUID FROM SYSMAN.MGMT$GROUP_MEMBERS WHERE group_name = 'all_databases')
ORDER BY 1;