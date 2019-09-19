set serveroutput on
set lines 32767

set lines 32767 pages 0 trims on
col cmd for a99999


-- RAC UNDO - 4x32GB
alter database datafile 3 resize 32767M;
alter database datafile 3 autoextend off;
alter database datafile 4 resize 32767M;
alter database datafile 4 autoextend off;

begin
  for i in 1..7
  loop
    execute immediate 'alter tablespace UNDOTBS1 add datafile size 32767M';
    execute immediate 'alter tablespace UNDOTBS2 add datafile size 32767M';
  end loop;
end;
/


-- TEMP - 4x32GB
alter database tempfile 1 autoextend on next 256M maxsize 32767M;

begin
  for i in 1..14
  loop
    execute immediate 'alter tablespace TEMP add tempfile size 256M autoextend on next 256M maxsize 32767M';
  end loop;
end;
/


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


-- SMALL FILE - pridani dalsich datafiles pres v_df_maxsize_mb
for i in 1..floor(p_maxsize_gb * 1024 / v_df_maxsize_mb)
LOOP
  v_sql := 'alter tablespace ' || DBMS_ASSERT.ENQUOTE_NAME(p_tablespace_name)
    || ' add ' || v_datafile_params || ' ' || v_df_maxsize_mb ||'M';
  run_sql(v_sql);
END LOOP;


-- UNDOTBS
-- RAC undo datafiles

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
