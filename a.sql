col dbname for a10
select sys_context('USERENV', 'DB_NAME') dbname, version, sum(e) is_shareable, sum(b) is_bind_aware, sum(a) is_bind_sensitive, sum(f) Total
from (
SELECT
  case when is_bind_sensitive = 'Y' THEN 1 ELSE 0 end a,
  case when is_bind_aware  = 'Y' THEN 1 ELSE 0 end b,
  case when is_shareable  = 'Y' THEN 1 ELSE 0 end e,
  1 f
FROM
  gv$sql 
  ) , v$instance
  group by version ;