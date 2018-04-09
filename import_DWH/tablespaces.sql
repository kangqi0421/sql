-- DWH tablespaces


-- pustit pres skript import_dwh.sh
-- nezapomenout na resize no BIGFILE datafiles
conn system/s

define maxsize = 32767
define max_pocet_datafiles = 2

set lines 32767 pages 0 trims on head off feed off verify off

prompt WHENEVER SQLERROR EXIT SQL.SQLCODE

prompt set echo on
prompt

WITH tbs AS (
  SELECT tablespace_name,
         SUM(bytes)/1048576 size_mb
    FROM dba_data_files@EXPORT_IMPDP
  -- mimo jiz existujici tablespaces
  WHERE  tablespace_name NOT IN (
         SELECT tablespace_name from dba_tablespaces
                               )
  GROUP BY tablespace_name ORDER BY tablespace_name
  )
SELECT 'CREATE '||
  CASE
    WHEN size_mb > &maxsize * &max_pocet_datafiles THEN 'BIGFILE '
    ELSE ''
  END ||
    'TABLESPACE '||tablespace_name||
    ' datafile size 512M autoextend on next 512M maxsize '||
  CASE
    WHEN size_mb > &maxsize * &max_pocet_datafiles THEN 'UNLIMITED'
    ELSE '&maxsize.M'
  END  || ';'
  -- ROUND(GREATEST(size_mb, &maxsize)) ||'M;'
  END
FROM TBS;

prompt exit
