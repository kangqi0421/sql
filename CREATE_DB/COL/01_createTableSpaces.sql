-- nastavit certifikaty dle:  02_SSL_unix_config.txt
--
connect / as sysdba

column db_name new_value db_name print
select sys_context('USERENV', 'DB_NAME') as db_name from dual;

SET ECHO ON
SET FEEDBACK ON

SPOOL &db_name._dbTablespaces.log
WHENEVER SQLERROR CONTINUE

@@dbTablespaces.sql_0

SET ECHO ON

SPOOL OFF

SPOOL &db_name._tallyman_locked.log

@@tallyman_locked.sql_0  -- vytvorit schema

SPOOL OFF

SPOOL &db_name._directory_CS_TALLYMAN_OPERATIONS.log

@@directory_CS_TALLYMAN_OPERATIONS.sql_0

spool off

SOOOL &db_name._dbUsersAndRights.log

@@dbUsersAndRights.sql_0 TALLYMAN

SPOOL OFF

BEGIN
  -- assign oSB prodution server host name and port interval
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL
    (acl  => 'webservices.xml',
     host => 'osb-st2.vs.csin.cz',   -- 'osb.cc.csin.cz'  -- production
     lower_port => 5001,
     upper_port => 5001);

  -- assign wallet path with certifikates for https protocol
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_ACL
    (acl =>  'webservices.xml',
     wallet_path => 'file:/etc/oracle/wallet');
END;
/

exit
