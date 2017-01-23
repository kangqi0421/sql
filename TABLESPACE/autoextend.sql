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

-- TEST = autoextend na maxsize na vsechny datafiles
BEGIN
  FOR rec IN (
     select file_id, autoextensible, maxbytes,
       -- pokud je incr mensi nez 256M, tak ho zvetsi na 256M
       CASE
         WHEN INCREMENT_BY * b.db_block_size /1024/1024  < 256  THEN 256
         ELSE INCREMENT_BY * b.db_block_size /1024/1024
       END incr
   from dba_data_files d join dba_tablespaces t
          on (d.tablespace_name = t.tablespace_name),
        (select value db_block_size from v$parameter where name = 'db_block_size') b
  where t.contents = 'PERMANENT'
    AND t.tablespace_name not in
          ('SYSTEM','SYSAUX','USERS','ARM_DATA')
              )
  LOOP
      execute immediate 'alter database datafile '|| rec.file_id
        || ' autoextend on next '|| rec.incr ||'M'
        || ' maxsize UNLIMITED';
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

--
-- autoextend CRM
/* nastav autoextend pro prM-avM-l jeden datafile per tablespace */
BEGIN
   FOR rec IN (SELECT file_id
          FROM (  SELECT tablespace_name,
                 file_name,
                 file_id,
                 bytes,
                 ROW_NUMBER ()
                    OVER (PARTITION BY tablespace_name ORDER BY BYTES)
                    rn
            FROM dba_data_files
           WHERE tablespace_name NOT IN
                    ('SYSTEM','SYSAUX','UNDOTBS','TEMP','TOOLS','ARMON_TS','ARM_DATA')
        ORDER BY 1)
 WHERE rn = 1
 )
LOOP
  execute immediate 'alter database datafile '||rec.file_id||' autoextend on next 512m maxsize 32767m';
END LOOP;
END;
/

/* tablespace pro LOAD - navM-mc pro nM-mM-^^e uvedenM-i tablespaces nastav autoextend pro vM-^Zechny datafiles */
BEGIN
   FOR rec
      IN (SELECT file_id
            FROM dba_data_files
           WHERE tablespace_name IN
                    ('SIEBSA_DATA','SIEBSA_INDX','SIEBEIM_DATA','SIEBEIM_INDX'))
   LOOP
      EXECUTE IMMEDIATE
            'alter database datafile '
         || rec.file_id
         || ' autoextend on next 512m maxsize 32767m';
   END LOOP;
END;
/


-- ODI_DATA
@ls ODI_DATA

BEGIN
   FOR rec
      IN (SELECT file_id
            FROM dba_data_files
           WHERE tablespace_name IN
                    ('ODI_DATA'))
   LOOP
      EXECUTE IMMEDIATE 'alter database datafile '
         || rec.file_id  || ' autoextend on next 512m maxsize 32767m';
   END LOOP;
END;
/

alter tablespace ODI_DATA
  add datafile  size 512m autoextend on next 512m maxsize 32767m;

@ls ODI_DATA