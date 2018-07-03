--
-- skript pro killnutí všech blokujících sessions
--

set pages 0 lines 180
select 'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id
  ||''' immediate ;'
  -- '||s.username||'@'||s.machine||' ('||s.program||') spid: '|| p.spid
from gv$session s inner join gv$process p
       ON (s.inst_id = p.inst_id and s.paddr=p.addr)
  where 1=1
  --  AND EVENT like 'row cache lock'
  and s.username = 'RMDREPDA_M'
  -- and action like 'UTL_RECOMP_SLAVE%'
  --and osuser = 'oracle'
  -- AND sql_id = 'azu104ujtd6yp'
  -- vsechny blokovane session
  --and sid in (
  --select blocking_session from v$session
  --where EVENT like 'enq: TX - row lock contention'
  --and final_blocking_session_status = 'VALID')
  -- and sql_id in (
  -- '8jd6fk9uzvrsf')
;
