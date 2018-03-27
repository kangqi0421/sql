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
--   and grantee = 'INT_OWNER'
  -- and type_name = 'java.io.FilePermission'
--   and name like '/srv/data/pred/ccd/cont/remote/fint/import/ctlp/int_owner'
  AND grantee in (
    select username from dba_users where oracle_maintained = 'N'
    )
  and ENABLED = 'ENABLED'
order by grantee, name, action desc
;

-- recreate JAVA permission
select 'exec '||stmt
  from (select seq, 'dbms_java.grant_permission('''||grantee||''','''||
        type_schema||':'||type_name||''','''||name||''','''||action||
        ''');' stmt
   from dba_java_policy
  where grantee IN (
    select username from dba_users where oracle_maintained = 'N')
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

-- MW DBEIM


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
               and grantee in ('MW'))
 loop
  dbms_java.disable_permission(rc.seq);
  dbms_java.delete_permission(rc.seq);
  commit;
 end loop;
end;
/

commit
/


-- INT_OWNER
exec dbms_java.grant_permission('INT_OWNER',  'SYS:java.io.FilePermission', 'FILE_LOC_CTLP', 'read,write');

exec DBMS_JAVA.GRANT_PERMISSION('INT_OWNER','SYS:java.io.FilePermission','/srv/data/pred/ccd/cont/remote/fint/Import/CTLT/int_owner/temp','read');


CREATE OR REPLACE procedure INT_OWNER.get_dirpath_list_pok( p_directory in varchar2 )
as language java
name 'DirListPok.getListPok( java.lang.String )';

--
CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED INT_OWNER."DirListPok" as import java.io.*;
import java.sql.*;
public class DirListPok
{
public static void getListPok(String directory)
                   throws SQLException
{
    File path = new File( directory );
    String[] list = path.list();
    String element;

  for(int i = 0; i < list.length; i++)

    {

        element = list[i];

        #sql { INSERT INTO TEMP_DIR_LIST (FILENAME)

               VALUES (:element) };

    }

}
}
/

ALTER JAVA SOURCE INT_OWNER."DirListPok" COMPILE;
exec  INT_OWNER.GET_DIRPATH_LIST_POK('/srv/data/pred/ccd/cont/remote/fint/Import/CTLT/int_owner/temp');

ALTER JAVA SOURCE INT_OWNER."DirList" COMPILE;
exec  INT_OWNER.get_dirpath_list_v2('/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp');
select count(*) from INT_OWNER.TEMP_DIR_LIST ;


exec  INT_OWNER.get_dirpath_list_v2('/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp');
select count(*) from INT_OWNER.TEMP_DIR_LIST ;

-- reload JVM

exec DBMS_JAVA.GRANT_PERMISSION('INT_OWNER','SYS:java.io.FilePermission','/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp','read');


-- WBLSYS
DBEIM OOBJCSOPSFILES  JAVA SOURCE 1 0 0 Note: OOBJCSOPSFILES uses or overrides a deprecated API.  ERROR 0
DBEIM OOBJCSOPSFILES  JAVA SOURCE 2 0 0 Note: Recompile with -Xlint:deprecation for details.  ERROR 0
DBEIM DIRUTILS  JAVA SOURCE 1 0 0 Note: Some input files use or override a deprecated API.  ERROR 0
DBEIM DIRUTILS  JAVA SOURCE 2 0 0 Note: Recompile with -Xlint:deprecation for details.  ERROR 0
DBEIM DIRUTILS  JAVA SOURCE 3 0 0 Note: DIRUTILS uses unchecked or unsafe operations. ERROR 0
DBEIM DIRUTILS  JAVA SOURCE 4 0 0 Note: Recompile with -Xlint:unchecked for details.  ERROR 0

