create or replace procedure CMD(p_cmd in varchar2)
as
  x number;
begin
  x := RUN_CMD(p_cmd);
end;
/




---

CREATE OR REPLACE and COMPILE JAVA SOURCE
NAMED "ExecuteOSCommand"
AS
import java.io.*;
import java.lang.*;
public class ExecuteOSCommand extends Object
{
  public static int RunThis(String args)
  {
    Runtime rt = Runtime.getRuntime();
    int        rc = -1;
    try
    {
       // System.out.println(args);
       Process p = rt.exec(args);

       int bufSize = 4096;
       BufferedInputStream bis =
        new BufferedInputStream(p.getInputStream(), bufSize);
       int len;
       byte buffer[] = new byte[bufSize];
       // Output of the program called
       while ((len = bis.read(buffer, 0, bufSize)) != -1)
            System.out.println(new String(buffer));
       rc = p.waitFor();
    }
    catch (Exception e)
    {
      e.printStackTrace();
      rc = -1;
    }
    finally
    {
      return rc;
    }
  }
}
/

create or replace function RUN_CMD( p_cmd  in varchar2)
return number
AS LANGUAGE JAVA
NAME  'ExecuteOSCommand.RunThis(java.lang.String) return integer';
/


-- shell script

#!/bin/bash
/bin/ping -c5 -i0.5 $1 1> /dev/null
exit $?


-- permission

begin
  dbms_java.grant_permission
    (
    'SCOTT',
    'java.io.FilePermission',
    '/opt/oracle/bin/ping.sh',
    'execute'
    );
  dbms_java.grant_permission
    (
    'SCOTT',
    'java.lang.RuntimePermission',
    'writeFileDescriptor',
    ''
    );
  dbms_java.grant_permission
    (
    'SCOTT',
    'java.lang.RuntimePermission',
    'readFileDescriptor',
    ''
    );
end;
/