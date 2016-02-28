set lines 180 pages 1000
set trims on

column owner format a15 heading 'owner'
column object_name format a30 heading 'object name'
column object_type format a20 heading 'object type'
column last_ddl_time format a20 heading 'last_ddl_time'

prompt
prompt invalid objects
prompt

select owner, object_type, object_name, last_ddl_time, status
from dba_objects
where status <> 'VALID'
order by owner, object_type;

prompt
prompt unusable dba_indexes
prompt

select owner, index_name, table_owner, table_name, status from dba_indexes where status = 'UNUSABLE'; 

prompt
prompt unusable dba_ind_partitions
prompt

select index_owner, index_name, partition_name, status from dba_ind_partitions where status = 'UNUSABLE'; 

prompt
prompt unusable dba_ind_subpartitions
prompt

select index_owner, index_name, subpartition_name, status from dba_ind_subpartitions where status = 'UNUSABLE'; 

