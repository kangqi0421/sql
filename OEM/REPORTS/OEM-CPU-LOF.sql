-- bar chart
with cpu_util as
(
select
   REPLACE(c.hostname,'ordb') hostname,
   a.rollup_timestamp,
   a.average*c.cpu_count/100 AVG_CPU
 FROM
   mgmt$metric_daily a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
  AND a.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND a.rollup_timestamp <= ??EMIP_BIND_END_DATE??
 AND REGEXP_LIKE(a.target_name, '^[pb]ordb0[0-9].vs.csin.cz')
--  AND REGEXP_LIKE(a.target_name, '^(zp|zb|t|d)ordb0[0-9].vs.csin.cz')
)
select hostname, avg(AVG_CPU) avg_cpu
  from cpu_util
group by hostname
order by substr(hostname,1,1)||substr(hostname,-1,2)

-- CPU usage per time - Time Series Line Chart
with cpu_util as with cpu_util as
(
select
   c.hostname,
   a.rollup_timestamp,
   a.average*c.cpu_count/100 AVG_CPU
 FROM
   mgmt$metric_daily a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
  AND a.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND a.rollup_timestamp <= ??EMIP_BIND_END_DATE??
 AND REGEXP_LIKE(a.target_name, '^[pb]ordb0[0-9].vs.csin.cz')
)
-- decode column to second column
select hostname, rollup_timestamp, AVG_CPU CPU_AVG_UTIL
  from cpu_util
--order by 2
;

-- MEM util
with mem_util as
(
select
   substr(a.target_name, 1, instr(a.target_name, '.')-1) target_name,
   -- REPLACE(substr(a.target_name, 1, instr(a.target_name, '.')-1), 'ordb') target_name,
   a.rollup_timestamp,
   a.average AVG
 FROM
   mgmt$metric_daily a
 where metric_name = 'Load' AND metric_column = 'memUsedPct'
 AND REGEXP_LIKE(a.target_name, '^(p|b|zp|zb|t|d)ordb0[0-9].vs.csin.cz')
  AND a.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND a.rollup_timestamp <= ??EMIP_BIND_END_DATE??
)
select target_name, round(avg(AVG)) MEM_AVG_UTIL
  from mem_util
group by target_name
order by substr(target_name,1,1)||substr(target_name,-1,2)
;