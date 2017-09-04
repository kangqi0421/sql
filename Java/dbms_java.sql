-- Java JDK test version
select dbms_java.get_jdk_version() from dual;

/*
ERROR at line 1:
ORA-29548: Java system class reported: release of classes.bin in the database
does not match that of the oracle executable
*/

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
   and type_name = 'java.io.FilePermission'
--   and name like '/srv/data/pred/ccd/cont/remote/fint/import/ctlp/int_owner'
;


-- Grant JAVA permission

-- pozor
-- nefunguje 'read,write' na jeden řádek ...

-- zmenit cestu prod, pred, test .. atd.
BEGIN
  dbms_java.grant_permission('INT_OWNER', 'SYS:java.io.FilePermission',
    '/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner',
    'read');
  dbms_java.grant_permission('INT_OWNER', 'SYS:java.io.FilePermission',
    '/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner',
    'write');
END;
/



-- testcase
begin
  int_owner.get_dirpath_list_v2('/srv/data/pred/ccd/cont/remote/fint/import/ctlp/int_owner');
end;
/

create or replace procedure           get_dirpath_list_v2( p_directory in varchar2 )
as language java
name 'DirList.getList( java.lang.String )';

--

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
