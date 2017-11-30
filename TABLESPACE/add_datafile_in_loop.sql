set serveroutput on
set lines 32767

set lines 32767 pages 0 trims on
col cmd for a99999

-- 6x datafile
select
 'alter tablespace CDM_MADB add datafile  size 512m autoextend on next 512m maxsize 32767m;'
 cmd
from dual
connect by
   level <= 6
/

-- 6x OUT
select
 'alter tablespace OUT_INDX add datafile ''+ODSP_D03'' size 512m autoextend on next 512m maxsize 65535M;'
   ||chr(10) ||
  'alter tablespace OUT_DATA add datafile ''+ODSP_D03'' size 512m autoextend on next 512m maxsize 65535M;'
 cmd
from dual
connect by
   level <= 6
/


begin
  for i in 1..ceil(8)  -- poèet v GB / maxsize per datafile 64G
  loop
    --dbms_output.put_line(i);
    dbms_output.put_line ('alter tablespace UNDOTBS1 add datafile size 512M autoextend on next 512M maxsize 32767M;');
    dbms_output.put_line ('alter tablespace UNDOTBS2 add datafile size 512M autoextend on next 512M maxsize 32767M;');
  end loop;
end;
/



-- resize UNDO datafile
DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE tablespace_name like 'UNDO%'
        AND AUTOEXTENSIBLE = 'YES';
BEGIN
   FOR rec IN c_datafile
   LOOP
      execute immediate 'alter database datafile '|| rec.file_id ||'  resize 16G';
   END LOOP;
END;
/