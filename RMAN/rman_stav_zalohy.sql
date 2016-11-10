-- pohled do v$session_longops
-- where context >1  - overall process progress 
SELECT sid, serial#, context, sofar, totalwork,
round(sofar/totalwork*100,2) completed
FROM v$session_longops
WHERE totalwork > 0
and upper(opname) like '%RMAN%'
and sofar <> totalwork
order by context, sid;

-- prùbìžný stav:
select * from V$RMAN_BACKUP_JOB_DETAILS;

-- koneèný stav (RMAN katalog):
select * from RC_RMAN_BACKUP_JOB_DETAILS;
