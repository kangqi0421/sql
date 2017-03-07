-- Java JDK test version
select dbms_java.get_jdk_version() from dual;
                                        *
ERROR at line 1:
ORA-29548: Java system class reported: release of classes.bin in the database
does not match that of the oracle executable

-- znovu pustit datapatch -verbose
$ORACLE_HOME/OPatch/datapatch -verbose

-- reload JVM
@?/javavm/install/update_javavm_db.sql

-- startup upgrade
@?/rdbms/admin/catnojav.sql
@?/rdbms/admin/catjava.sql

--
-- List existing privs
--
select * from sys.DBA_JAVA_POLICY
where 1=1
   and grantee = 'INT_OWNER'
--   and type_name = 'java.io.FilePermission'
;

-- Grant JAVA permission
-- zmenit cestu prod, pred, test .. atd.
exec  dbms_java.grant_permission('INT_OWNER',
  'java.io.FilePermission',
  '/srv/data/pred/ccd/cont/remote/fint/Import/CTLT/int_owner',
  'read,write');

prompt
prompt Revoke existing privs

begin
 for rc in (select seq from sys.DBA_JAVA_POLICY
             where type_name = 'java.io.FilePermission'
               and grantee in ('INT_OWNER'))
 loop
  dbms_java.disable_permission(rc.seq);
  dbms_java.delete_permission(rc.seq);
  commit;
 end loop;
end;
/

commit
/
