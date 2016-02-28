select
  'TRACEFILE=' ||
  i.value || '/' ||
  lower(sys_context('userenv', 'instance_name')) || '_ora_' ||
  p.spid || upper(nvl2(p.traceid, '_' || p.traceid, null)) || '.trc'
from v$process p,
  v$session s,
  v$parameter i
where s.audsid = sys_context('userenv','sessionid')
  and s.paddr = p.addr
  and i.name = 'user_dump_dest';