col name for a35
col value for 999999

-- vypis memory parametru
prompt NON-DEFAULT memory target, sga a pga
SELECT name,
  value/1048576 "value [MB]",
  isdefault
FROM V$SYSTEM_PARAMETER
WHERE name IN ('memory_target','memory_max_target','sga_max_size','sga_target',
         'shared_pool_size','db_cache_size','java_pool_size','large_pool_size','streams_pool_size',
			   'pga_aggregate_target','pga_aggregate_limit')
AND isdefault = 'FALSE'
;

-- SGA a PGA memory target rozdìlení
prompt memory target
SELECT component, current_size/1048576 "current [MB]" FROM v$memory_dynamic_components
   WHERE component LIKE '%Target';

prompt SGA
prompt ===
select INST_ID, name, round(bytes/1048576) "MB"
   --, RESIZEABLE
  from gv$sgainfo
-- where name like 'Large%'
order by name, inst_id
;

prompt SGA_TARGET_ADVICE pro factor +- 5%
prompt MIN, pokud = 1, nema smysl SGA snizovat
prompt MAX, pokud = 2, nema smysl SGA navysovat (cim mensi hodnota, tim vetši efekt bude mit navyseni SGA)
-- minimální velikost SGA do 5% poklesu úèinnosti buffer cache a možnost
-- nutné navýšení SGA pro zlepšení úèinnosti o 5%
col min_sga for a20
col max_sga for a20
SELECT  INST_ID, MIN(SGA_SIZE_FACTOR)||' ('||MIN(SGA_SIZE)/1024||'G)' min_sga,
    MAX(SGA_SIZE_FACTOR)||' ('||MAX(sga_size)/1024||'G)' max_sga
  FROM GV$SGA_TARGET_ADVICE
 WHERE ESTD_DB_TIME_FACTOR BETWEEN 0.95 AND 1.05
 GROUP BY INST_ID;

prompt PGASTAT
prompt =======
select name,
  case
     when unit = 'bytes' then round(value/1048576)
  else value
  end value,
     decode (unit,'bytes','MB') UNIT
 from v$pgastat
  where name in ('aggregate PGA target parameter','aggregate PGA auto target','total PGA allocated','maximum PGA allocated',
				 'cache hit percentage','over allocation count');

prompt PGA_TARGET_ADVICE pro factor -25% +40%
prompt PGA_CACHE_HIT_PERCENTAGE, pokud se hodnota vyrazne nenavysuje, nema cenu PGA pridavat
SELECT   PGA_TARGET_FACTOR,
    ROUND(PGA_TARGET_FOR_ESTIMATE/1048576) "PGA_FOR_ESTIMATE [MB]",
    ESTD_PGA_CACHE_HIT_PERCENTAGE
  FROM V$PGA_TARGET_ADVICE
  WHERE PGA_TARGET_FACTOR BETWEEN 0.75 AND 1.4;