set termout on 
set feedback off colsep ; lines 32767 trimspool on trimout on tab off 
set underline off
set pages 0

col dbname for a10

SELECT SYS_CONTEXT ('USERENV', 'DB_NAME')  as dbname,
       average,
       maximum,
       fra,
       CASE WHEN maximum > fra THEN 'ERR' ELSE 'OK' END status
  FROM (SELECT TRUNC (AVG (mb)) average, TRUNC (MAX (mb)) maximum
          FROM (  SELECT TRUNC (COMPLETION_TIME),
                         SUM (blocks * block_size) / 1048576 / 1024 AS mb
                    FROM v$archived_log
                GROUP BY TRUNC (COMPLETION_TIME))) a,
       (SELECT TRUNC (VALUE / 1048576 / 1024) fra
          FROM v$parameter
         WHERE name LIKE 'db_recovery_file_dest_size') b;
