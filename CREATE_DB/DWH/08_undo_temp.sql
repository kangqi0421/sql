--
-- UNDO TEMP
--


-- USER TEMP bigfile
create bigfile temporary tablespace USER_TEMP
  tempfile size 10G autoextend on next 1G maxsize UNLIMITED;
alter database default temporary tablespace USER_TEMP;

-- App TEMP tablespace
drop tablespace TEMP;
create bigfile temporary tablespace TEMP
  tempfile size 10G autoextend on next 1G maxsize UNLIMITED;


-- UNDO bigfile
create bigfile undo tablespace UNDOTBS2 datafile
  size 10G autoextend on next 1G maxsize 406G;
alter system set undo_tablespace = UNDOTBS2 ;
