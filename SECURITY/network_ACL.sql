--
-- DBA_NETWORK_ACLS
--

-- co grantuju
SELECT * FROM DBA_HOST_ACLS;

-- komu grantuju
select * from dba_network_acl_privileges;


 SELECT host, lower_port, upper_port, acl
     FROM dba_network_acls
   ORDER BY 1;


-- create ACLs
BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'MW',
    description  => 'MW ACL Control List',
    principal    => 'BOS_OWNER',
    is_grant     => TRUE,
    privilege    => 'connect');

  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'MW',
    host        => 'int-mw.vs.csin.cz');

END;
/

-- check
SELECT DECODE(DBMS_NETWORK_ACL_ADMIN.check_privilege('MW', 'BOS_OWNER', 'connect'),1, 'GRANTED', 0, 'DENIED', NULL) privilege FROM dual;

SELECT *
  FROM xds_acl;

-- drop
BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL (acl => 'MW' );
  COMMIT;
END;
/

-- OCM network ACL
/sys/acls/oracle-sysman-ocm-Resolve-Access.xml

select * from dba_network_acl_privileges;

-- drop the entire ACL if it is the one we created
BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL('oracle-sysman-ocm-Resolve-Access.xml');
  commit;
END;
/

--
select acl from dba_network_acl_privileges;

