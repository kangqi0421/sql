-- aktualni stav:

define tablespace = DAT_DATA


select df.TABLESPACE_NAME,
      round(alloc) alloc,
      round(autoextend) autoextend,
      round(free) free
from
(
SELECT
  tablespace_name,
  SUM(bytes_alloc)/1048576 alloc,
  SUM(bytes_total /1048576) autoextend
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
GROUP BY tablespace_name ) df join
(SELECT   tablespace_name,
    SUM (BYTES/1048576) free
  FROM dba_free_space
  group by tablespace_name) free on (df.tablespace_name = free.tablespace_name)
 where df.TABLESPACE_NAME  in ('&tablespace')
;


set pages 0 lines 32767 trims on
--// resize datafile dle HWM //--
with query as (
    select /*+ NO_MERGE MATERIALIZE */
        file_id,
        tablespace_name,
        max(block_id + blocks) highblock
    from dba_extents
    group by file_id, tablespace_name
)
select
    -- resize to highblock + 1 db block in MB
    'alter database datafile '|| q.file_id || ' resize ' || ceil ((q.highblock * t.block_size + t.block_size)/1024)  || 'k;' cmd
from
    query q, dba_tablespaces t, dba_data_files df
where
    q.tablespace_name = t.tablespace_name
    and q.tablespace_name = df.tablespace_name
    and q.file_id = df.file_id
    and q.highblock < df.user_blocks 	-- pouze pokud je shrink resize < df.bytes
    and q.tablespace_name in ('&tablespace')
;

--// Segmenty z dba_extents k uvolneni pro shrink, posledn?h 5 pro kazdy datafile //--
SELECT   *
  FROM
    (
      SELECT   file_id,
          owner,
          segment_name,
          PARTITION_NAME,
          SEGMENT_TYPE,
          BLOCK_ID,
          row_number() over(partition BY file_id order by block_id DESC) RN
        FROM DBA_EXTENTS
        WHERE FILE_ID IN
          (
            SELECT   file_id
              FROM DBA_DATA_FILES
              WHERE tablespace_name = '&tablespace'
          )
        ORDER BY RN
    )
  WHERE RN <= 5
  ORDER BY FILE_ID,
    block_id DESC;

--// resize datafile with no extents in - df size = free space //--

with query as (
  SELECT a.tablespace_name,
         a.file_id,
         ROUND (a.user_bytes / 1048576) alloc,
         ROUND (b.free / 1048576) free,
         a.autoextensible
    FROM    dba_data_files a
         INNER JOIN
            (  SELECT file_id, SUM (bytes) free
                 FROM dba_free_space
             GROUP BY file_id) b
         ON a.file_id = b.file_id
   WHERE a.user_bytes = b.free
ORDER BY b.free DESC
)
select
    'alter database datafile '|| q.file_id || ' resize 256m;' cmd
from
    query q
where
    q.free > 256
    and q.alloc > 256;


