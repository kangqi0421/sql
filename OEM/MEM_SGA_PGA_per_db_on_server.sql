define server=pctldb01

-- Memory init params
SELECT
   --host_name,
   target_name,  name, --value,
   round(value/1048576/1024) "GB",
   sum(value/1048576/1024) over ()
 FROM MGMT$DB_INIT_PARAMS
 where
    name in ('memory_target','sga_target','pga_aggregate_target')
--    AND target_name like 'CLM%'
    AND host_name like '&server%'
--  REGEXP_LIKE(host_name, '^[p]ordb0[0-5].vs.csin.cz')
--  REGEXP_LIKE(host_name, 'z?(t|d|p|b)ordb0[0-5].vs.csin.cz')
    and value > 0
order by target_name, name;

-- MGMT$DB_SGA
select host_name, target_name, collection_timestamp, sganame, sgasize
  from   sysman.MGMT$DB_SGA
 where  target_name like 'MDWP%';

-- SGA per db on server
SELECT
   m.target_name,
   round(avg(m.average)) SGA
FROM
  MGMT$METRIC_DAILY m join mgmt$target t on (M.target_GUID = t.TARGET_GUID)
WHERE  1 = 1
  AND T.HOST_NAME like '&server%'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'sga_total'
AND m.rollup_timestamp > interval '3' month
  group by m.target_name
order by SGA desc;

-- PGA per db on server
SELECT
    m.rollup_timestamp,
   m.target_name,
   m.maximum PGA
FROM
  MGMT$METRIC_DAILY m join mgmt$target t on (M.target_GUID = t.TARGET_GUID)
WHERE  1 = 1
  --AND T.HOST_NAME like '&server%'
  and m.target_name like 'CTLP'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'pga_total'
AND m.rollup_timestamp > sysdate - interval '3' month
--  group by m.target_name
order by 1 desc;