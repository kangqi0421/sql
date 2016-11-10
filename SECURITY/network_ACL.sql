select * from DBA_NETWORK_ACLS;

-- OCM network ACL
/sys/acls/oracle-sysman-ocm-Resolve-Access.xml

select * from dba_network_acl_privileges;

-- drop the entire ACL if it is the one we created
BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL('oracle-sysman-ocm-Resolve-Access.xml');
  commit;
END;
/
