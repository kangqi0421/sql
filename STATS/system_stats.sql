# SYSTEM stats
* (http://blog.dbi-services.com/oracle-system-statistics-display-auxstats-with-calculated-values-and-formulas/)

## No Workload (NW) stats:

CPUSPEEDNW - CPU speed
IOSEEKTIM - The I/O seek time in milliseconds
IOTFRSPEED - I/O transfer speed in milliseconds

## Workload-related stats:

SREADTIM  - Single block read time in milliseconds
MREADTIM - Multiblock read time in ms
CPUSPEED - CPU speed
MBRC - Average blocks read per multiblock read (see db_file_multiblock_read_count)
MAXTHR - Maximum I/O throughput (for OPQ only)
SLAVETHR - OPQ Factotum (slave) throughput (OPQ only)

MBRC - pokud není hodnota spočtena, pak se derivuje z _db_file_optimizer_read_count=8

--
SELECT DECODE(pname,
'CPUSPEED','CPUSPEED: (Workload) CPU speed in millions of cycles/second',
'CPUSPEEDNW','CPUSPEEDNW: (No Workload) CPU speed in millions of cycles/second',
'IOSEEKTIM','IOSEEKTIM: Seek time + latency time + operating system overhead time in milliseconds',
'IOTFRSPEED','IOTFRSPEED: Rate of a single read request in bytes/millisecond',
'MAXTHR','MAXTHR: Maximum throughput that the I/O subsystem can deliver in bytes/second',
'MBRC','MBRC: Average multiblock read count sequentially in blocks',
'MREADTIM','MREADTIM: Average time for a multi-block read request in milliseconds',
'SLAVETHR','SLAVETHR: Average parallel slave I/O throughput in bytes/second',
'SREADTIM','SREADTIM: Average time for a single-block read request in milliseconds'
) AS statistic,
pval1 AS value
FROM SYS.aux_stats$
WHERE pname IN ('CPUSPEEDNW',
'IOSEEKTIM','IOTFRSPEED',
'SREADTIM','MREADTIM',
'CPUSPEED','MBRC',
'MAXTHR','SLAVETHR')
AND sname = 'SYSSTATS_MAIN'
ORDER BY pname;


column pname format a20
SELECT pname, pval1
  FROM SYS.aux_stats$
WHERE sname = 'SYSSTATS_MAIN';

-- Exadata
exec dbms_stats.set_system_stats(pname => 'MBRC',       pvalue => 128);

-- export SYSTEM stats
exec dbms_stats.create_stat_table(user,'STAT_TIMESTAMP');
exec dbms_stats.export_system_stats('STAT_TIMESTAMP');

-- calculated values
select pname,pval1,calculated,formula from sys.aux_stats$ where sname='SYSSTATS_MAIN'
model
  reference sga on (
    select name,value from v$sga
        ) dimension by (name) measures(value)
  reference parameter on (
    select name,decode(type,3,to_number(value)) value from v$parameter where name='db_file_multiblock_read_count' and ismodified!='FALSE'
    union all
    select name,decode(type,3,to_number(value)) value from v$parameter where name='sessions'
    union all
    select name,decode(type,3,to_number(value)) value from v$parameter where name='db_block_size'
        ) dimension by (name) measures(value)
partition by (sname) dimension by (pname) measures (pval1,pval2,cast(null as number) as calculated,cast(null as varchar2(60)) as formula) rules(
  calculated['MBRC']=coalesce(pval1['MBRC'],parameter.value['db_file_multiblock_read_count'],parameter.value['_db_file_optimizer_read_count'],8),
  calculated['MREADTIM']=coalesce(pval1['MREADTIM'],pval1['IOSEEKTIM'] + (parameter.value['db_block_size'] * calculated['MBRC'] ) / pval1['IOTFRSPEED']),
  calculated['SREADTIM']=coalesce(pval1['SREADTIM'],pval1['IOSEEKTIM'] + parameter.value['db_block_size'] / pval1['IOTFRSPEED']),
  calculated['   multi block Cost per block']=round(1/calculated['MBRC']*calculated['MREADTIM']/calculated['SREADTIM'],4),
  calculated['   single block Cost per block']=1,
  formula['MBRC']=case when pval1['MBRC'] is not null then 'MBRC' when parameter.value['db_file_multiblock_read_count'] is not null then 'db_file_multiblock_read_count' when parameter.value['_db_file_optimizer_read_count'] is not null then '_db_file_optimizer_read_count' else '= _db_file_optimizer_read_count' end,
  formula['MREADTIM']=case when pval1['MREADTIM'] is null then '= IOSEEKTIM + db_block_size * MBRC / IOTFRSPEED' end,
  formula['SREADTIM']=case when pval1['SREADTIM'] is null then '= IOSEEKTIM + db_block_size        / IOTFRSPEED' end,
  formula['   multi block Cost per block']='= 1/MBRC * MREADTIM/SREADTIM',
  formula['   single block Cost per block']='by definition',
  calculated['   maximum mbrc']=sga.value['Database Buffers']/(parameter.value['db_block_size']*parameter.value['sessions']),
  formula['   maximum mbrc']='= buffer cache size in blocks / sessions'
)
;

-- poměr seq reads a scattered read
select
   round(sum(b.time_waited_micro)/sum(b.total_waits)/1000,2) "sequential read [ms]",
   round(sum(a.time_waited_micro)/sum(a.total_waits)/1000,2) "scattered read  [ms]",
   round((
      sum(a.total_waits) /
      sum(a.total_waits + b.total_waits)
   ) * 100,1) "scattered reads %",
   round((
      sum(b.total_waits) /
      sum(a.total_waits + b.total_waits)
   ) * 100) "sequential reads %",
  (
      sum(b.time_waited_micro) /
      sum(b.total_waits)) /
      (sum(a.time_waited_micro)/sum(a.total_waits)
   ) * 100 c5
from
   dba_hist_system_event a, -- db file scattered read
   dba_hist_system_event b  -- db file sequential read
where a.snap_id = b.snap_id
   and a.event_name = 'db file scattered read'
   and b.event_name = 'db file sequential read'
;