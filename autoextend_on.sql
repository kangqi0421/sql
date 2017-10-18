--
-- SQL skript nastaví autoextend pro datafiles na UNLIMITED
--

BEGIN
  FOR rec IN (
         select
           file_id,
           autoextensible,
           -- ROUND(b.db_block_size * 4096/1024-1) maxsize,
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
