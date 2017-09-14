
-- dba_thresholds na tablespaces
SELECT   metrics_name, object_name, warning_value, critical_value
    FROM dba_thresholds
   WHERE OBJECT_TYPE = 'TABLESPACE'
ORDER BY metrics_name, object_name;


-- tablespace zaplněna na více než 30
select TABLESPACE_NAME, tablespace_size*8/1024, used_space*8/1024, 
     round(USED_PERCENT )
  from   DBA_TABLESPACE_USAGE_METRICS
  where USED_PERCENT > 30
;

-- free space vcetne autoextendu - pouziva OEM pro monitoring
SELECT m.tablespace_name,
       round((m.tablespace_size - m.used_space) * 8 / 1024) "actual free space",
       t.metrics_name, 
       t.CRITICAL_VALUE,
       t.warning_value
  FROM DBA_TABLESPACE_USAGE_METRICS m, DBA_THRESHOLDS t
 WHERE T.OBJECT_TYPE = 'TABLESPACE'
 --    AND t.metrics_name LIKE 'Tablespace Bytes Space Usage'
       AND t.object_name = M.TABLESPACE_NAME
--       AND m.tablespace_name = 'SIEB_INDEX_SML'
ORDER by m.tablespace_name, t.metrics_name ;

@ls RTPE_BOOKING

alter tablespace RTPE_BOOKING add datafile  size 512m autoextend on next 512m maxsize  32767m;


-- vypis datafiles, pouze platnych
select * from v$filespace_usage where flag = 2;

-- velikost datafiles "s/bez" autoextendu
SELECT
  tablespace_name,
  SUM(bytes_alloc)/1048576 "alloc [MB]" ,
  SUM(bytes_total /1048576) "autoextend [MB]"
FROM
  (
    SELECT
      tablespace_name,
      bytes bytes_alloc,
      CASE
        WHEN autoextensible = 'NO'     THEN BYTES
        WHEN autoextensible = 'YES'    THEN maxbytes
      END bytes_total
    FROM
      dba_data_files
  )
WHERE
  tablespace_name = 'SIEB_INDEX_SML' 
GROUP BY tablespace_name;


-- free space within datafiles bez autoextendu
select sum(bytes)/1048576 from dba_free_space 
  where tablespace_name = 'SODS_DATA';