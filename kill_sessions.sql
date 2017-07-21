--
-- MCIP cursor: pin S wait on X
--

-- skript pro killnutí všech blokujících sessions

set lines 180
select 'alter system kill session '''||sid||','||serial#||',@'||inst_id||''' -- '
       ||username||'@'||machine||' ('||program||');'
from gv$session
  where 1=1
  --  AND EVENT like 'row cache lock'
  and username = 'RMDB_ODI_USER'
  -- AND sql_id = 'azu104ujtd6yp'
  -- vsechny blokovane session
  --and sid in (
  --select blocking_session from v$session
  --where EVENT like 'enq: TX - row lock contention'
  --and final_blocking_session_status = 'VALID')
;
