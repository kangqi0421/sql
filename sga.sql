-- SGAINFO
col name for a35
select name, round(bytes/1048576) "MB", RESIZEABLE
  from gv$sgainfo
 --where name like 'Large%'
;

-- historie = DBA_HIST_SGASTAT
--select * from v$sga_dynamic_components;

-- SGA resize operations V$SGA_RESIZE_OPS
-- pokud je hodnì èastý, pak je tøeba upravit
--  * "_memory_broker_stat_interval=999" - starší verze do 11.2.0.2
--  * shared_pool_size na minimal hodnotu, pod kterou neklesne automatika
SELECT COMPONENT ,OPER_TYPE,FINAL_SIZE/1048576 Final,start_time
  FROM GV$SGA_RESIZE_OPS
  where 1=1
  -- AND component in ('DEFAULT buffer cache', 'shared pool')
  AND start_time > sysdate - 7
order by start_time desc, component;

-- Historie resize OPS
select
    *
	-- start_time, oper_type, component, initial_size/1048576/1024, final_size/1048576/1024
  from DBA_HIST_MEMORY_RESIZE_OPS
 where component = 'shared pool'
 and start_time > sysdate - 7
order by start_time;

-- BUFFER CACHE
/*
-- DEAL_FACTS - blocks# cached in the buffer cache
select count(*)
        FROM V$BH
        WHERE OBJD in (SELECT DATA_OBJECT_ID FROM DBA_OBJECTS WHERE OBJECT_NAME='DEAL_FACTS')
                and status='xcur';

-- status buffer cache
SELECT SUM(DECODE(bh.status, 'free', 1, 0)) AS free,
       SUM(DECODE(bh.status, 'xcur', 1, 0)) AS xcur,
       SUM(DECODE(bh.status, 'scur', 1, 0)) AS scur,
       SUM(DECODE(bh.status, 'cr', 1, 0)) AS cr,
       SUM(DECODE(bh.status, 'read', 1, 0)) AS read,
       SUM(DECODE(bh.status, 'mrec', 1, 0)) AS mrec,
       SUM(DECODE(bh.status, 'irec', 1, 0)) AS irec
FROM   v$bh bh;

*/

/*
RDSPA:
RDSTB:

*/