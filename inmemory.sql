-- Inmemory advisor

RTOTP_task_01

|                                                                      |
|                                    ESTIMATED      ESTIMATED          |
|                                    ANALYTICS      ANALYTICS          |
|                                    PROCESSING    PROCESSING          |
|                    PERCENTAGE         TIME       PERFORMANCE         |
|         IN-MEMORY  OF MAXIMUM      REDUCTION     IMPROVEMENT         |
|           SIZE      SGA SIZE       (SECONDS)*      FACTOR*           |
|         ---------  ----------  ----------------  -----------         |
|           71.56GB      143          52183          2.1X              |
|           67.98GB      136          52181          2.1X              |
|           64.41GB      129          52170          2.1X              |
|           60.83GB      122          52135          2.1X              |
|           57.25GB      114          52039          2.1X              |
|           53.67GB      107          51906          2.1X              |
|           50.09GB      100          51670          2.1X              |
|           46.51GB       93          51187          2.1X              |
|           42.94GB       86          50728          2.0X              |
|           39.36GB       79          50313          2.0X              |
|           35.78GB       72          49538          2.0X              |
|           32.20GB       64          49428          2.0X              |
|           28.62GB       57          48721          2.0X              |
|           25.05GB       50          47527          1.9X              |
|           21.47GB       43          45614          1.8X              |
|           17.89GB       36          44998          1.8X              |
|           14.31GB       29          44710          1.8X              |
|           10.73GB       21          43481          1.8X              |
|           7.156GB       14          42477          1.7X              |
|           3.578GB       7           40167          1.7X              |
|                                                                      |
| *Estimates: The In-Memory Advisor's estimates are useful for making  |
|  In-Memory decisions.  But they are not precise.  Due to performance |
|  variations caused by workload diversity, the Advisor's performance  |
|  estimates are conservatively limited to no more than 10.0X          |
|  faster.                                                             |
|                                                                      |



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
