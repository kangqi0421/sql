
-- 12.1.0.2
Bug 26324206 - DBA_TABLESPACE_USAGE_METRICS.USED_PERCENT IS INCORRECT AFTER UPGRADE TO 12.2
--

define tablespace = ODI_DATA

-- tablespace_size = sum(max_size) for autoextensible tablespace which corresponds to maxblocks in dba_data_files.
--
select
--    m.*,
    m.TABLESPACE_NAME,
    round(tablespace_size * block_size/power(1024,3)) size_GB,
    round(used_space * block_size /power(1024,3)) used_GB,
    round(USED_PERCENT)
  from   DBA_TABLESPACE_USAGE_METRICS m
         INNER JOIN DBA_TABLESPACES t ON (m.TABLESPACE_NAME = t.TABLESPACE_NAME)
  where 1 = 1
--    AND USED_PERCENT > 30
    AND m.tablespace_name = '&tablespace'
;

-- dba_thresholds na tablespaces
SELECT   metrics_name, object_name, warning_value, critical_value
    FROM dba_thresholds
   WHERE OBJECT_TYPE = 'TABLESPACE'
ORDER BY metrics_name, object_name;


-- definice DBA_TABLESPACE_USAGE_METRICS
-- používá strukturu x$kttets
SELECT  t.name,
        tstat.kttetsused,
        tstat.kttetsmsize,
        (tstat.kttetsused / tstat.kttetsmsize) * 100
  FROM  sys.ts$ t, x$kttets tstat
  WHERE
        t.online$ != 3 and
        t.bitmapped <> 0 and
        t.contents$ = 0 and
        bitand(t.flags, 16) <> 16 and
        t.ts# = tstat.kttetstsn
        and t.name = 'MDM'
;

-- vypis datafiles, pouze platnych
-- v$filespace_usage se již nepoužívá
select sum(file_maxsize*8)/power(1024,2),
       sum(allocated_space*8)/power(1024,2)
 from v$filespace_usage
  where tablespace_id in (select TS# from sys.ts$
                             where name = '&tablespace')
-- AND flag = 2
order by rfno;

select * from sys.ts$
  where name = '&tablespace';


select *
     from   dba_data_files
   WHERE tablespace_name = '&tablespace'
;

select value from v$parameter where name like 'db_block_size';

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
--       AND m.tablespace_name = '&tablespace'
ORDER by m.tablespace_name, t.metrics_name ;

@ls RTPE_BOOKING

alter tablespace RTPE_BOOKING add datafile  size 512m autoextend on next 512m maxsize  32767m;



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
  tablespace_name = '&tablespace'
GROUP BY tablespace_name;


-- free space within datafiles bez autoextendu
select sum(bytes)/1048576 from dba_free_space
  where tablespace_name = '&tablespace'
;