-- SYSAUX na min.8GB
BEGIN
FOR REC IN (
  -- vyber SYSAUX datafiles, pokud je maxsize < 8GB
  select file_id
  from (
  select min(file_id) file_id,
  sum(CASE autoextensible WHEN 'YES' THEN maxbytes else bytes end)/1024/1024/1024 gb
    from dba_data_files
   where tablespace_name = 'SYSAUX'
  ) where gb < 8)
  LOOP
    -- nastav AUTOEXTEND nd 8G
    EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| ' autoextend on next 256M maxsize 8G';
  END LOOP;  
END;
/


-- SYSTEM, SYSAUX, USERS, TEMP - autoextend na 1GB
define datafile_maxsize = 8G

DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE tablespace_name in ('SYSTEM', 'SYSAUX', 'USERS');
   CURSOR c_tempfile
   IS
      SELECT file_id FROM dba_temp_files;
BEGIN
   -- datafile SYSTEM, SYSAUX, UNDOTBS1, USERS
   FOR rec IN c_datafile
   LOOP
      EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend on next 128m maxsize &datafile_maxsize';
	  --EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend off';
   END LOOP;
   FOR rec IN c_tempfile
   LOOP
      EXECUTE IMMEDIATE 'alter database tempfile '|| rec.file_id|| '  autoextend on next 128m maxsize &datafile_maxsize';
	  --EXECUTE IMMEDIATE 'alter database tempfile '|| rec.file_id|| '  autoextend off';
   END LOOP;
END;
/


-- UNDO - change fixed size na 4GB
define datafile_maxsize = 4G

DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE tablespace_name in (
		select tablespace_name from dba_tablespaces where contents = 'UNDO'
		);
BEGIN
   -- datafile UNDOTBS1, UNDOTBS2
   FOR rec IN c_datafile
   LOOP
      EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  resize &datafile_maxsize';
	  EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend off';
   END LOOP;
END;
/