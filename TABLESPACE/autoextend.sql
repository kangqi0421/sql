/* opravy AUTOEXTENDu u datafiles /*

/* zrus autoextend u datafiles, kde BYTES dosahlo MAXBYTES */
DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE BYTES >= (MAXBYTES - (INCREMENT_BY * (select value from v$parameter where name = 'db_block_size')))
        AND AUTOEXTENSIBLE = 'YES';
BEGIN
   FOR rec IN c_datafile
   LOOP
      execute immediate 'alter database datafile '|| rec.file_id ||'  autoextend off';
   END LOOP;
END;
/

-- autoextend on na vsechny datafiles
BEGIN
   FOR rec IN (SELECT file_id
                 FROM dba_data_files
                where
                 tablespace_name in ('OUT_DATA','OUT_INDX')
        )
   LOOP
      execute immediate 'alter database datafile '|| rec.file_id ||' autoextend on next 512m maxsize 65535m';
   END LOOP;
END;
/



/* nastav MAXBYTES na 2GB, kde MAXBYTES = UNLIMITED */
DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE MAXBLOCKS = 4194303 - 1;
   CURSOR c_tempfile
   IS
      SELECT file_id
        FROM dba_temp_files
       WHERE MAXBLOCKS = 4194303 - 1;
BEGIN
   FOR rec IN c_datafile
   LOOP
      execute immediate 'alter database datafile '|| rec.file_id ||'  autoextend on next 256m maxsize 16G';
   END LOOP;
   FOR rec IN c_tempfile
   LOOP
      execute immediate 'alter database tempfile '|| rec.file_id ||'  autoextend on next 256m maxsize 2G';
   END LOOP;
END;
/

/* nastav autoextend on next 256M u datafiles, kde je minimální autoincr */
set serveroutput on

DECLARE
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE AUTOEXTENSIBLE = 'YES' AND INCREMENT_BY = 1;
BEGIN
   FOR rec IN c_datafile
   LOOP
      execute immediate 'alter database datafile '|| rec.file_id ||'  autoextend on next 256m';
   END LOOP;
END;
/
