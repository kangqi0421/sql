-- PGA basic stats
select name,
  case
     when unit = 'bytes' then round(value/1048576)
  else value
  end value,
     decode (unit,'bytes','MB') UNIT
 from v$pgastat
  where name in ('aggregate PGA target parameter','total PGA allocated','maximum PGA allocated','cache hit percentage');

-- ALL PGA stats
select name, 
       case 
         when unit = 'bytes' then round(value/1048576)
	 else value
       end value,
       decode (unit,'bytes','MB')
  from v$pgastat;

-- SQL workarea active
select  sid, sql_id, active_time, operation_type,
	actual_mem_used, max_mem_used, 
	work_area_size, tempseg_size 
  from V$SQL_WORKAREA_ACTIVE
order by actual_mem_used;

-- v$process_memory, detailne pak dotaz do v$process_memory_detail po zavolani
-- ORADEBUG SETMYPID; 
-- ORADEBUG DUMP PGA_DETAIL_GET &pid;
SELECT   pid, CATEGORY,
    round(allocated/POWER(1024,2)),
    round(used/power(1024,2))
  FROM v$process_memory
  WHERE pid IN (
      SELECT   pid  FROM v$process WHERE addr IN (
            SELECT   paddr  FROM v$session
              WHERE sql_id = 'cck32amvj9156'
          )
    )
order by allocated desc;  

-- sort usage
select sql_id, contents, blocks from v$sort_usage;

-- PGA AWR
-- MAX PGA a TEMP allocated
SELECT   trunc(sample_time, 'hh24'),
        round(MAX(PGA_ALLOCATED)/1024/1024)      MAX_PGA,
        round(MAX(TEMP_SPACE_ALLOCATED)/1048576) MAX_TEMP
 --   FROM GV$ACTIVE_SESSION_HISTORY
           FROM dba_hist_active_sess_history
  WHERE 1     =1
    and sample_time >  TRUNC(sysdate) - 2
    --        AND SQL_PLAN_OPERATION = 'HASH JOIN'
  GROUP BY trunc(sample_time, 'hh24')
  ORDER BY trunc(sample_time, 'hh24')
 ;


-- PGA AWR
-- total PGA allocated hour by hour for yesterday
SELECT   instance_number,
    name,
    TO_CHAR (begin_interval_time, 'dd.mm.yyyy hh24:mi') "date",
    ROUND(MAX(value)/(1024*1024)) "MB"
  FROM sys.dba_hist_snapshot NATURAL
  JOIN sys.dba_hist_pgastat pgastat
  WHERE begin_interval_time > TRUNC(systimestamp) - 14
  AND dbid =
    (
      SELECT   dbid
        FROM v$database
    )
  AND name = 'total PGA allocated'
  GROUP BY instance_number,
    name,
    begin_interval_time
  ORDER BY instance_number,
    begin_interval_time;