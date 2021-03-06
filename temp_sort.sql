--
-- TEMP SORT PGA
--

select  sid, sql_id, active_time, operation_type,
  actual_mem_used, max_mem_used,
  work_area_size, tempseg_size
  from GV$SQL_WORKAREA_ACTIVE
 where tempseg_size > 0
order by actual_mem_used;


select * from dba_tablespaces
 where contents = 'TEMPORARY';

-- V$TEMPSEG_USAGE - new versions
select s.username, round(sum(s.blocks * value)/power(1024,3)) "GB"
  from GV$TEMPSEG_USAGE s, v$parameter p
    where name = 'db_block_size'
  group by s.username
  order by 2 desc;

-- starsi verze 12
select s.sid, s.serial#, s.username,
       sort.username, s.state, s.event,
       s.logon_time,
       sort.blocks
  from V$SORT_USAGE sort join v$session s
    on (sort.session_addr = s.saddr)
  where tablespace = 'TEMP'
   -- and s.username = 'DAMI_ETL_OWNER'
;


with temp as (
select username, sql_id_tempseg, blocks*block_size bs
  from V$SORT_USAGE s join dba_tablespaces t
        on s.tablespace = t.tablespace_name
 where tablespace = 'TEMP'
 )
select username, sql_id_tempseg, sum(bs)/power(1024,2) GB
  from temp
group by username, sql_id_tempseg
 order by 3 desc;


/* TEMP as BIGFILE
- pro RAC nepoužívat

create bigfile temporary tablespace bigtemp;
alter database default temporary tablespace bigtemp;
drop tablespace temp;
create bigfile temporary tablespace temp;
alter database default temporary tablespace temp;
drop tablespace bigtemp;

*/