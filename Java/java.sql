--
-- Java
--


SYS	FILE_LOC_CTLP	/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp	0
SYS	FILE_LOC_CTLT	/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp	0

exec dbms_java.grant_permission('INT_OWNER',  'SYS:java.io.FilePermission', 'FILE_LOC_CTLP', 'read,write');


exec DBMS_JAVA.GRANT_PERMISSION('INT_OWNER','SYS:java.io.FilePermission','/srv/data/pred/ccd/cont/remote/fint/Import/CTLT/int_owner/temp','read');

--,'read,write,delete');

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

select * from dba_directories
 where directory_name like 'FILE%';

ALTER JAVA SOURCE INT_OWNER."DirListPok" COMPILE;
exec  INT_OWNER.GET_DIRPATH_LIST_POK('/srv/data/pred/ccd/cont/remote/fint/Import/CTLT/int_owner/temp');

ALTER JAVA SOURCE INT_OWNER."DirList" COMPILE;
exec  INT_OWNER.get_dirpath_list_v2('/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp');
select count(*) from INT_OWNER.TEMP_DIR_LIST ;


exec  INT_OWNER.get_dirpath_list_v2('/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp');
select count(*) from INT_OWNER.TEMP_DIR_LIST ;

-- reload JVM



exec DBMS_JAVA.GRANT_PERMISSION('INT_OWNER','SYS:java.io.FilePermission','/srv/data/prod/ccd/cont/remote/fint/import/ctlp/int_owner/temp','read');