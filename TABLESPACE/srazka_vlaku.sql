SELECT SUBSTR (d.file_name, 1, INSTR (d.file_name, '/', -1) - 1) fs,
         ROUND ( (SUM (d.maxbytes - d.BYTES)) / 1048576) "nutno odecist od AVAIL [MB]"
    FROM dba_data_files d, dba_tablespaces t
   WHERE     t.status != 'READ ONLY'
         AND d.tablespace_name = t.tablespace_name
         AND d.autoextensible = 'YES'
         AND d.maxbytes - d.BYTES > 0
GROUP BY SUBSTR (d.file_name, 1, INSTR (d.file_name, '/', -1) - 1);