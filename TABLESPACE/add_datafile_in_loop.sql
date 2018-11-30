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

-- RAC undo datafiles
alter database datafile 3 resize 65535M;
alter database datafile 3 autoextend off;
alter database datafile 4 resize 65535M;
alter database datafile 4 autoextend off;

-- add UNDOTBS datafiles
BEGIN
   FOR rec IN (
      select tablespace_name from dba_tablespaces
        where contents = 'UNDO')
   LOOP
     for i in 1..10
     loop
       execute immediate 'alter tablespace '||rec.tablespace_name
           ||' add datafile size 65535M';
     end loop;
   END LOOP;
END;
/
