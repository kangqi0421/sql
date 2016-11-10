-- CPU count, CPU Used per sec, MEM z OEM MGMT$METRIC_DAILY

-- average daily CPU usage per second
SELECT 
   m.rollup_timestamp,
   target_name,
   m.average/100 avg_value
FROM
  MGMT$METRIC_DAILY m
WHERE  1 = 1
AND metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
AND m.rollup_timestamp > sysdate - interval '7' day
AND m.TARGET_GUID IN (
  SELECT TARGET_GUID
    FROM MGMT_TARGETS
    WHERE target_type LIKE '%database'
      AND host_name LIKE 'pctldb01%')
order by M.Rollup_Timestamp;

-- detailed CPU usage per second
SELECT 
   m.COLLECTION_TIMESTAMP,
   --target_name,
   m.value/100 value
FROM
  MGMT$METRIC_DETAILS m
WHERE  1 = 1
AND metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
--AND m.COLLECTION_TIMESTAMP > sysdate - interval '2' day
AND m.TARGET_GUID IN (
  SELECT TARGET_GUID
    FROM MGMT_TARGETS
    WHERE target_type LIKE '%database'
      AND host_name LIKE 'pctldb01%'
      AND target_name in 'CTLP'
                      )
order by 1;


select * from
-- CPU usage z METRIC
(with cpu as (
-- average z maxima CPU per day
SELECT
   target_name,
   'CPU_usage' name,
   round(avg(m.maximum)/100,2) value
FROM
  MGMT$METRIC_DAILY m
WHERE  1 = 1
AND metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
AND m.rollup_timestamp > sysdate - 31
 group by m.target_name, 'CPU_usage'
)
-- CPU, MEM z DB init params
SELECT
  target_name,
  name,
  to_number(i.value) value
 FROM MGMT$DB_INIT_PARAMS i
 where target_name in
('ODIDA_dordb02.vs.csin.cz','DLKDA_dordb02.vs.csin.cz','ODITA_tordb02.vs.csin.cz',
 'DLKTA','ODIZA_ODIZA1','DLKZA_DLKZA1','ODIP_ODIP1','DLKP_DLKP1')
 and i.name in ('cpu_count','memory_target','sga_target','pga_aggregate_target')
UNION
 select
  target_name,
  name,
  value
 FROM cpu
  where target_name in
('ODIDA_dordb02.vs.csin.cz','DLKDA_dordb02.vs.csin.cz','ODITA_tordb02.vs.csin.cz',
 'DLKTA','ODIZA_ODIZA1','DLKZA_DLKZA1','ODIP_ODIP1','DLKP_DLKP1')
ORDER by target_name, NAME
)
PIVOT
( max(value)
  for name in ('cpu_count','CPU_usage','memory_target','sga_target','pga_aggregate_target') )
;
