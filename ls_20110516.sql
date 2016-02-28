set lines 237 pages 999 verify off serveroutput on size 20000

col tablespace_name for a30
col file_name for a60

-- definuje vhodnou velikost datafile v GB
define dfSize = 32
undefine tablespace_name

SELECT   tablespace_name, file_name, BYTES / 1048576 "MB", autoextensible
        ,(INCREMENT_BY * (select value from v$parameter where name = 'db_block_size'))/1048576 "inc MB"
        , maxbytes/1048576 "max MB"
 FROM dba_data_files
     WHERE tablespace_name = upper('&&tablespace_name')
 ORDER BY 1, SUBSTR (file_name, INSTR (file_name, '/', -1, 1) + 1);

--/* volne misto ve FS */--
--  begin
--     dbms_output.put_line('FS to use:');
--     dbms_output.new_line;
--     dbms_output.put('! bdf ');
--    for i in (select distinct  SUBSTR (file_name, 1, (INSTR (file_name, '/', -1, 1) - 1)) as fs from dba_data_files
--      WHERE tablespace_name = '&&tablespace_name')
--    loop
--      dbms_output.put( i.fs || ' ');
--    end loop;
--    dbms_output.put(' | sort -n -k 4 | awk ''$4 > 110000''');
--    dbms_output.new_line;
--  end;
--  /
      
prompt Volne misto v ASM po odecteni autoextendu:

SELECT ROUND( (SELECT TOTAL_MB / 1024 GB
          FROM V$ASM_DISKGROUP
         WHERE name LIKE '%D01')
-
(SELECT (  a.data_size
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
       )) "free [MB]"
FROM DUAL;

prompt Vhodny kandidat pro resize - prvni datafile bez autoextendu se size < &dfSize.g

set head off
SELECT 'alter database datafile '''||file_name||'''  resize &dfSize.g;' 
  FROM (SELECT file_name, ROW_NUMBER () OVER (ORDER BY file_name) R
          FROM dba_data_files
         WHERE     tablespace_name = UPPER ('&&tablespace_name')
               AND autoextensible = 'NO'
               AND bytes / 1048576 /1024 < &dfSize
               order by file_id)
 WHERE R = 1;
set head on
