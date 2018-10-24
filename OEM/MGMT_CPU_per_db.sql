--
-- OEM CPU Usage
--

define server = pordb04.vs.csin.cz

-- pocty CPU cores a CPU_COUNT
CM$MGMT_DB_CPU_USAGE_ECM

-- CPU Usage per database
SELECT
   m.COLLECTION_TIMESTAMP,
   --m.target_name,
   d.DATABASE_NAME db_name,
   m.value "CPU"
FROM
       MGMT$METRIC_DETAILS m
  join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
  JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE  1 = 1
  AND m.metric_name = 'instance_efficiency' AND m.metric_column = 'cpuusage_ps'
  AND t.host_name like :server
order by 1, 2
;

-- CPU resmgr:cpu quantum
SELECT
   m.COLLECTION_TIMESTAMP,
   d.DATABASE_NAME db_name,
   t.host_name,
   m.value "CPU resmgr totalWaitTime"
FROM
       MGMT$METRIC_DETAILS m
  join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
  JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE  1 = 1
  AND m.metric_name = 'topWaitEvents'  AND m.metric_column = 'totalWaitTime'
  AND key_value like 'resmgr:cpu quantum'
  AND t.host_name like :server
  and m.COLLECTION_TIMESTAMP > sysdate - interval '7' day
order by 1, 2
;

-- CPU usage, daily, last month
SELECT
   m.rollup_timestamp,
   --m.target_name,
   CASE
      -- orezani podtrzitka v target name
      WHEN instr(m.target_name, '_') > 0
        THEN substr(m.target_name, 1, instr(m.target_name, '_')-1)
      -- orezani domeny targetu s teckou
      WHEN instr(m.target_name, '.') > 0
        THEN substr(m.target_name, 1, instr(m.target_name, '.')-1)
      -- vrat puvodni nazev
      ELSE m.target_name
   END DB,
   round(m.average/100,2) "CPU"
FROM
  --MGMT$METRIC_HOURLY m
  MGMT$METRIC_DAILY m
    join MGMT_TARGETS t on (t.TARGET_GUID = m.target_guid)
WHERE  1 = 1
  AND m.metric_name = 'instance_efficiency' AND m.metric_column = 'cpuusage_ps'
  AND m.rollup_timestamp > sysdate - interval '1' month
  AND m.target_name like 'RTO%'
  --AND REGEXP_LIKE(t.host_name, '^z?[pbtd]ordb0[0-9].vs.csin.cz')
  -- AND t.host_name like 'dordb04.vs.csin.cz'
order by 1, 2
;

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

