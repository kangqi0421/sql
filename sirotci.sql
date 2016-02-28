SELECT pid, spid, USERNAME, SERIAL#, PROGRAM, pga_used_mem, pga_alloc_mem, pga_freeable_mem, pga_max_mem 
FROM v$process  WHERE spid IN
  (
  SELECT p.spid FROM v$process p
  MINUS
  SELECT p.spid FROM v$session s, v$process p WHERE s.paddr = p.addr
  );

SELECT spid
FROM   v$process
WHERE NOT EXISTS (SELECT 1
                  FROM v$session
                  WHERE paddr = addr);

