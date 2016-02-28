--
-- check compress for table
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