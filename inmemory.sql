select * from v$sga;

select * from dba_tables
where inmemory = 'ENABLED'
  and table_name like 'TEST%'
;

select POOL, ROUND(ALLOC_BYTES/1024/1024/1024,2) as "ALLOC_BYTES_GB", 
  ROUND(USED_BYTES/1024/1024/1024,2) as "USED_BYTES_GB",
  populate_status 
 from V$INMEMORY_AREA; 


SELECT mem inmem_size,
       tot disk_size,
       bytes_not_pop,
       (tot/mem) compression_ratio,
       100 *((tot-bytes_not_pop)/tot) populate_percent
FROM
  (SELECT SUM(INMEMORY_SIZE)/1024/1024/1024 mem,
    SUM(bytes)              /1024/1024/1024 tot ,
    SUM(bytes_not_populated)/1024/1024/1024 bytes_not_pop
   FROM v$im_segments
   ) 
/

SELECT segment_name, inmemory_size, inmemory_compression, 
       bytes/inmemory_size comp_ratio
FROM v$im_segments;
