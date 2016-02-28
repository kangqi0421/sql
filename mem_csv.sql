-- MEM parametry
SELECT   sys_context('USERENV', 'DB_NAME')||';'|| LISTAGG(name||';'||value/
    1048576,';') within GROUP (ORDER BY name)||';' AS mem
  FROM V$PARAMETER
  WHERE name IN ('memory_max_target','memory_target','pga_aggregate_target',
    'sga_max_size','sga_target')
    --AND ISDEFAULT = 'FALSE' 
;

-- PGA nastaveni
SELECT   sys_context('USERENV', 'DB_NAME')||';'|| LISTAGG(name||';'||value,';') within GROUP (ORDER BY name)||';' AS pga
from (
select name,
  case
     when unit = 'bytes' then round(value/1048576)
  else value
  end value,
     decode (unit,'bytes','MB') UNIT
 from v$pgastat
  where name in ('aggregate PGA target parameter','maximum PGA allocated',
				 'cache hit percentage','over allocation count')
);