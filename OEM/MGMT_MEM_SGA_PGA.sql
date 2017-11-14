--
-- Memory
--

define server = dpsymdb01.vs.csin.cz

-- Server MEM utilization
-- MEM util, MEM free a MEM total free pres vsechny servery
select
   m.rollup_timestamp,
   substr(m.target_name, 1, instr(m.target_name, '.')-1) target_name,
   -- REPLACE(substr(a.target_name, 1, instr(a.target_name, '.')-1), 'ordb') target_name,
   ROUND(m.maximum,2) "MEM max util [%]",
   ROUND(m.maximum * mem/100/1024) "MEM util [GB]",
   ROUND((mem - (m.maximum * mem/100))/1024) "MEM free [GB]",
   ROUND(sum((mem - (m.maximum * mem/100))/1024)
     over (PARTITION BY m.rollup_timestamp)) "MEM free all [GB]"
 FROM
   mgmt$metric_daily m join MGMT$OS_HW_SUMMARY h  -- dotahuje velikost RAM
    on (m.target_name = h.host_name)
 where
--       metric_name = 'Load' AND metric_column = 'memUsedPct'
       -- logical used memory - trošku rozumnější hodnoty s hugepages
       metric_name = 'Load' AND metric_column = 'usedLogicalMemoryPct'
   AND m.target_name like '&server%'
--   AND REGEXP_LIKE(m.target_name, '^(t|d)ordb[0-9][0-9].vs.csin.cz')
--   AND REGEXP_LIKE(m.target_name, '^(p|b|zp|zb|t|d)ordb0[0-9].vs.csin.cz')
   AND m.rollup_timestamp > sysdate - interval '1' month
   -- AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name
;


-- SGA a PGA - real allocated size MB
AND m.metric_name = 'memory_usage' AND m.metric_column = 'total_memory'

-- SGA
CM$MGMT_DB_SGA_ECM


-- Memory init params
SELECT
--   *
   host_name,
   target_name,  name, --value,
   round(value/1048576/1024) "GB",
   ROUND(sum(value/1048576/1024) over ()) "SUM GB"
--   ROUND(sum(value/1048576/1024) over (PARTITION BY target_name)) "SUM GB"
 FROM MGMT$DB_INIT_PARAMS
 where
    name in ('memory_target','sga_target','pga_aggregate_target')
--    AND (target_name like 'PDBD%'
--      or target_name like 'SYMDA%'
--      )
    and host_name like '&server%'
--    AND REGEXP_LIKE(host_name, '^(p|b)ordb05.vs.csin.cz')
--     AND REGEXP_LIKE(host_name, '^z(p|b)ordb\d+.vs.csin.cz')
--     and target_name not like '%2'
    and value > 0
order by target_name, name;

-- MGMT$DB_SGA
select host_name, target_name, collection_timestamp, sganame, sgasize
  from   MGMT$DB_SGA
 where  target_name like 'MDWZA%';

-- SGA per db on server
SELECT
   m.target_name,
   round(avg(m.average)) SGA
FROM
  MGMT$METRIC_DAILY m join mgmt$target t on (M.target_GUID = t.TARGET_GUID)
WHERE  1 = 1
  AND T.HOST_NAME like '&server%'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'sga_total'
AND m.rollup_timestamp > sysdate - interval '1' month
  group by m.target_name
order by SGA desc;

-- PGA per db on server
SELECT
   m.rollup_timestamp,
   m.target_name,
   round(m.maximum) PGA
FROM
  MGMT$METRIC_DAILY m join mgmt$target t on (M.target_GUID = t.TARGET_GUID)
WHERE  1 = 1
  AND T.HOST_NAME like '&server%'
--  and m.target_name like 'CTLP'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'pga_total'
AND m.rollup_timestamp > sysdate - interval '1' month
--  group by m.target_name
order by 1 desc;

-- HugePages
SELECT
   --host_name,
    target_name,
    name, --value,
    round(value / 1048576 / 1024) "GB",
    SUM(value / 1048576 / 1024) OVER(),
    SUM(value / 1024) OVER() / 2048 hugepages
FROM
    mgmt$db_init_params
WHERE
    name IN (
        'sga_target'
    )
    AND   host_name LIKE '&server%'
    --and value > 0
ORDER BY  target_name,  name;
