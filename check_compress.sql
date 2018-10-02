--
-- check compress for table
--  ADVANCED COMPRESSION (introduced in 11.1)
--
--  ALERT Bug 21682261 Corruption during Recovery after upgrading to 12c for Compressed Tables
--

select count(*)
from dba_tables
where compress_for in ('ADVANCED','QUERY LOW','QUERY HIGH','ARCHIVE LOW','ARCHIVE HIGH');

select count(*)
from dba_tab_partitions
where compress_for in ('ADVANCED','QUERY LOW','QUERY HIGH','ARCHIVE LOW','ARCHIVE HIGH');

select count(*)
from dba_tab_subpartitions
where compress_for in ('ADVANCED','QUERY LOW','QUERY HIGH','ARCHIVE LOW','ARCHIVE HIGH');


set lines 180 pages 999
COL OWNER          FORMAT A20 WRAP
COL TABLE_NAME     FORMAT A30 WRAP
COL PARTITION_NAME FORMAT A30 WRAP
col compress_for   for a10

select a.owner, a.table_name, '' as partition_name, a.compression, a.compress_for
  from dba_tables a
  where a.compress_for in ('FOR ALL OPERATIONS', 'OLTP', 'ADVANCED')
union all
select a.table_owner, a.table_name, partition_name, a.compression, a.compress_for
  from dba_tab_partitions a
  where a.compress_for in ('FOR ALL OPERATIONS', 'OLTP', 'ADVANCED')
union all
select a.table_owner, a.table_name, partition_name, a.compression, a.compress_for
  from dba_tab_subpartitions a
  where a.compress_for in ('FOR ALL OPERATIONS', 'OLTP', 'ADVANCED')
order by 1, 2, 3, 4;
