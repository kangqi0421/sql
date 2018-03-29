--
-- UNDO TEMP
--

-- TEMP bigfile
create bigfile temporary tablespace tempbig
  tempfile size 10G autoextend on next 1G maxsize UNLIMITED;
alter database default temporary tablespace tempbig;

-- UNDO bigfile
create bigfile undo tablespace UNDOTBS2 datafile
  size 10G autoextend on next 1G maxsize 406G;
alter system set undo_tablespace = UNDOTBS2 ;
