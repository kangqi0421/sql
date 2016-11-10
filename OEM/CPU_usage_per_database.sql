
-- CPU Usage per database
SELECT
   m.rollup_timestamp,
   target_name,
   m.average value
FROM
  MGMT$METRIC_DAILY m join MGMT_TARGETS t
WHERE  1 = 1
AND metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
AND m.rollup_timestamp > sysdate - interval '3' month
AND target_name in ('CTLP','CTLRP')
order by M.Rollup_Timestamp

-- CPU Usage v OEM
SELECT
   --m.rollup_timestamp,
   trim('_' from substr(m.target_name,instr(m.target_name,'_'))) dbinst,
   round(avg(m.average)/100,1) "CPU usage per db"
FROM
  MGMT$METRIC_DAILY m join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
WHERE  1 = 1
  AND m.metric_name = 'instance_efficiency' AND m.metric_column = 'cpuusage_ps'
  AND m.rollup_timestamp >= ??EMIP_BIND_START_DATE??
  AND m.rollup_timestamp <= ??EMIP_BIND_END_DATE??
  --AND m.rollup_timestamp > sysdate - interval '3' month
  AND REGEXP_LIKE(t.host_name, '^z?[pbtd]ordb0[0-9].vs.csin.cz')
group by m.target_name
having avg(m.average) > 50
order by 2 desc


-- CPU Usage per time
with cpu_util as
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
select hostname, rollup_timestamp, AVG_CPU
  from cpu_util
--order by 2

