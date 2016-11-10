-- limit datafile maxsize for SYSTEM, UNDO and TEMP datafiles

-- define variables
define system_size = &1
define undo_size = &2
define temp_size = &3


-- SYSTEM, SYSAUX, USERS
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
      EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend on next 256M maxsize &system_size';
	  --EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend off';
   END LOOP;
   FOR rec IN c_tempfile
   LOOP
      EXECUTE IMMEDIATE 'alter database tempfile '|| rec.file_id|| '  autoextend on next 256M maxsize &system_size';
	  --EXECUTE IMMEDIATE 'alter database tempfile '|| rec.file_id|| '  autoextend off';
   END LOOP;
END;
/

-- UNDO
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
--      EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  resize &undo_size';
      EXECUTE IMMEDIATE 'alter database datafile '|| rec.file_id|| '  autoextend on next 256M maxsize &undo_size';
   END LOOP;
END;
/

-- ARM_DATA
BEGIN EXECUTE IMMEDIATE 'create tablespace ARM_DATA datafile size 256M autoextend on next 256M maxsize 16G'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- TEMP
alter database tempfile 1 autoextend on next 256M maxsize &temp_size;

-- RAC TEMP: pridani tempfile pro kazdou RAC instanci
DECLARE
  v_pocet_inst      int;
  v_pocet_tempfiles int;
BEGIN
  select count(*) into v_pocet_inst      from gv$instance;
  select count(*) into v_pocet_tempfiles from dba_temp_files;
  IF v_pocet_tempfiles < v_pocet_inst THEN
    for i in 1..(v_pocet_inst - v_pocet_tempfiles)
    loop
      execute immediate 'alter tablespace TEMP add tempfile size 256M autoextend on next 256M maxsize &temp_size';
    end loop;
  END IF;
END;
/

