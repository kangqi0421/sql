set pages 999 verify off 

col tablespace_name for a30
col file_name for a65

-- definuje vhodnou velikost datafile v GB
define dfSize = 32767
--define dfSize = 16384

SELECT    tablespace_name
	, file_id
	, file_name
	, BYTES / 1048576 "MB"
	, autoextensible
        ,(INCREMENT_BY * (select value from v$parameter where name = 'db_block_size'))/1048576 "inc MB"
        , maxbytes/1048576 "max MB"
 FROM (select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes, increment_by from dba_data_files
       union all
       select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes, increment_by from dba_temp_files
      )
     WHERE upper(tablespace_name) like upper('&1')
 --ORDER BY tablespace_name, file_name  -- ASM
   ORDER BY tablespace_name, SUBSTR (file_name, INSTR (file_name, '/', -1, 1) + 1) -- Filesystem
/

      
prompt Volne misto v ASM po odecteni autoextendu:

SELECT ROUND( (SELECT TOTAL_MB / 1024 GB
          FROM V$ASM_DISKGROUP
         WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_create_file_dest'))
-
(SELECT (        a.data_size
               + b.temp_size
               + c.redo_size
               + d.cf_size
               + e.bct_size) /1024/1024/1024  GB
  FROM
       (SELECT SUM (DECODE (autoextensible, 'YES', maxbytes, bytes)) data_size FROM dba_data_files) a,
       (SELECT NVL (SUM (DECODE (autoextensible, 'YES', maxbytes, bytes)) , 0) temp_size FROM dba_temp_files) b,
       (SELECT SUM (bytes) redo_size FROM v$log) c,
       (SELECT SUM (block_size * file_size_blks) cf_size FROM v$controlfile)   d,
       (SELECT NVL (bytes, 0) bct_size FROM v$block_change_tracking) e
       )) "free [GB]"
FROM DUAL;

prompt Vhodny kandidat pro resize - prvni datafile se size < &dfSize.m

set head off
SELECT    'alter database datafile '
       || file_id || ' '
       || CASE autoextensible WHEN 'YES' THEN 'autoextend on next 256m maxsize ' ELSE 'resize ' END
       || '&dfSize.m;'
  FROM (  SELECT file_id, bytes, autoextensible, 
	         ROW_NUMBER () OVER (PARTITION BY autoextensible ORDER BY file_id) R
            FROM dba_data_files
           WHERE     UPPER (tablespace_name) LIKE UPPER ('&&1')
                 --AND autoextensible = 'NO'
                 AND bytes < &dfSize * 1048576
        ORDER BY file_id)
 WHERE R = 1;
set head on
