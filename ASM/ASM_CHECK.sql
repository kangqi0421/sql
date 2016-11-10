/* odhadem free space v ASM po odeètení autoextendu */

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



