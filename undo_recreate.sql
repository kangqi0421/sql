
-- inst id #1
CREATE UNDO TABLESPACE "UNDOTBS1_TEMP" DATAFILE  SIZE 20G;
alter system set undo_tablespace = UNDOTBS1_TEMP scope=both sid='MCISTB1';
-- kontrola ONLINE undo segmentů
drop tablespace UNDOTBS1 including contents and datafiles;
CREATE UNDO TABLESPACE UNDOTBS1 DATAFILE  SIZE 30G;
alter system set undo_tablespace = UNDOTBS1 scope=both sid='MCISTB1';
-- kontrola ONLINE undo segmentů
drop tablespace UNDOTBS1_TEMP including contents and datafiles;

-- inst id #2
CREATE UNDO TABLESPACE "UNDOTBS2_TEMP" DATAFILE SIZE 20G;
alter system set undo_tablespace = UNDOTBS2_TEMP scope=both sid='MCISTB2';
-- kontrola ONLINE undo segmentů
drop tablespace UNDOTBS2 including contents and datafiles;
CREATE UNDO TABLESPACE UNDOTBS2 DATAFILE  SIZE 30G;
alter system set undo_tablespace = UNDOTBS2 scope=both sid='MCISTB2';
-- kontrola ONLINE undo segmentů
drop tablespace UNDOTBS2_TEMP including contents and datafiles;

-- UNDO segmenty in USE - ONLINE/OFFLINE
select TABLESPACE_NAME, STATUS, count(*) from dba_rollback_segs where tablespace_name like 'UNDO%' group by  TABLESPACE_NAME, STATUS;

-- ověření init parametrů
set lin 180
col name for a40
col value for a40
select inst_id, name, value from gv$parameter where name like 'undo_tablespace' order by 1;

-- UNDO file# and size
select tablespace_name, file_id, bytes/1048576 from dba_data_files where tablespace_name like 'UNDO%';