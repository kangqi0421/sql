--
-- Small Tables
--

- _small_table_threshold is derived as 2% of the db_cache_size

col name for a40
col value for a10
SELECT x.ksppinm name,y.ksppstvl value
  FROM x$ksppi  x,x$ksppcv y  WHERE x.indx = y.indx AND x.ksppinm like '_small_table_threshold';

NAME                                     VALUE
---------------------------------------- ----------
_small_table_threshold                   32799


select owner, bytes/1048576, blocks from  dba_segments
  where segment_name = 'CBLOG';

owner                        MB     BLOCKS
-------------------- ---------- ----------
INET_CSINT                  267      34176
INET_CSEXT                   23       2944