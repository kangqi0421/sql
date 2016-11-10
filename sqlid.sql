SET VERIFY OFF LINES 180

col sql_child_number head CH# for 99
col sql_sql_text head SQL_TEXT format a150 word_wrap
col users_executing format 999

prompt SQLID &1 child &2 from V$SQL

-- sql text
select
	hash_value,
	child_number	sql_child_number,
	sql_text sql_sql_text
from
	v$sql
where
	sql_id = ('&1')
    and child_number like '&2'
order by
	sql_id,
	hash_value,
	child_number
/


-- v$sql
select
	child_number	sql_child_number,
--	address		parent_handle,
--	child_address   object_handle,
	plan_hash_value plan_hash,
	nvl2(sql_profile,'Y','N')
	  || '/'||nvl2(sql_patch,'Y','N') "PROFILE/PATCH",
	parse_calls parses,
	loads h_parses,
  users_executing,
	executions,
	--fetches,
	rows_processed,
    round(rows_processed/nullif(fetches,0),2) rows_per_fetch,
	-- elapsed/cpu time per execution
	round(elapsed_time/1000/NULLIF(executions,0),0) AVG_ETIME_MS,
	round(cpu_time/1000/NULLIF(executions,0),2) AVG_CPUTIME_MS,
	-- LIOS/PIOS per execution
	round(buffer_gets/NULLIF(executions,0)) LIOS,
	round(disk_reads/NULLIF(executions,0)) PIOS,
	sorts
--	address,
--	sharable_mem,
--	persistent_mem,
--	runtime_mem,
--   , PHYSICAL_READ_REQUESTS
--   , PHYSICAL_READ_BYTES
--   , PHYSICAL_WRITE_REQUESTS
--   , PHYSICAL_WRITE_BYTES
--   , IO_CELL_OFFLOAD_ELIGIBLE_BYTES
--   , IO_INTERCONNECT_BYTES
--   , IO_CELL_UNCOMPRESSED_BYTES
--   , IO_CELL_OFFLOAD_RETURNED_BYTES
from
	v$sql
where
	sql_id = ('&1')
    and child_number like '&2'
order by
	sql_id,
	hash_value,
	child_number
/
