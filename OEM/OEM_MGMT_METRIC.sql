-- MGMT historic data
-- Sample SQL Query To Get History Information Of A Metric From Repository Database (Doc ID 828994.1)

--
http://jbaskar.blogspot.cz/2011/08/oms-grid-console-exploring-using-sql.html

http://petewhodidnottweet.com/2016/07/selecting-data-repository/

http://docs.oracle.com/cd/E63000_01/EMVWS/toc.htm

-- MGMT_VIEW - read only přístup z BI Publisheru, data source EMREPOS

-- hezký přehled view dostupných view, rozdělených dle kategorií
https://docs.oracle.com/cd/E24628_01/doc.121/e24474/ch2_db_mgmt.htm#OEMLI133

-- RAW data
MGMT$METRIC_CURRENT   -  Stores the current metrics from the past 24 hours
MGMT$METRIC_DETAILS   -  Stores details upto 7 days
-- agregovane
MGMT$METRIC_HOURLY    -  Stores details upto 31 days in a hourly snapshot with AVG, MIN and MAX values.
MGMT$METRIC_DAILY     -  Stores the metrics in a daily snapshot format with AVG, MIN and MAX values. - 12 months

-- RAW GC$ metrics
em_metric_values
em_metric_values_hourly
em_metric_values_daily

sysman.gc$metric_values_hourly

-- HW metriky
CM$MGMT_ECM_HW
MGMT$OS_HW_SUMMARY
MGMT$HW_CPU_DETAILS

select metric_item_id
      ,collection_time
      ,met_values
  from em_metric_values
 where rownum < 11;

-- retention periods
select table_name, partitions_retained
from em_int_partitioned_tables
where table_name in ('EM_METRIC_VALUES','EM_METRIC_VALUES_HOURLY','EM_METRIC_VALUES_DAILY');



-- hledani metriky
select distinct metric_name, metric_column, metric_label, column_label
  from mgmt$metric_current
 where
   --metric_name like '%pga%'  '%Network%' 'Redo%'
   column_label like '%Filesystem%'
   --metric_column like 'cursors'
  AND target_name like 'pasbo%'
;

-- BACKUP
MGMT$HA_BACKUP

-- CPU util server
AND metric_name = 'Load' AND metric_column = 'cpuUtil'

-- CPU util v DB
AND metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'
AND metric_name = 'wait_bottlenecks' AND metric_column = 'user_cpu_time_cnt'


-- Memory util server
AND metric_name = 'Load' AND metric_column = 'memUsedPct'
-- pro AIX: Used Logical Memory (%)
metric_column = usedLogicalMemoryPct

-- SGA a PGA Total Memory [MB]
AND m.metric_name = 'memory_usage' AND m.metric_column = 'total_memory'

-- SGA
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'sga_total'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'shared_pool'
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'buffer_cache'

-- PGA allocated
AND m.metric_name = 'memory_usage_sga_pga' AND m.metric_column = 'pga_total'
--AND m.metric_name = 'db_inst_pga_alloc' AND m.metric_column = 'total_pga_allocated'

-- I/O server
AND m.metric_name = 'DiskActivitySummary'
  AND m.metric_column = 'totiosmade'
  AND column_label like 'Total Disk I/O made across all disks (per second)'
--
AND m.metric_name = 'DiskActivitySummary'
  AND m.metric_column = 'maxavserv'
  AND column_label like 'Max Average Disk I/O Service Time (ms) amongst all disks'

-- Disk Reads (per second) - tohle je per disk, na serveru
AND m.metric_name = 'DiskActivity' AND m.metric_column = 'diskActivReadsPerSec'
  AND column_label like 'Disk Reads (per second)'

-- IO Database
-- I/O Megabytes (per second) - database
AND m.metric_name = 'instance_throughput' AND m.metric_column = 'iombs_ps'

-- I/O Requests (per second) - database
AND m.metric_name = 'instance_throughput' AND m.metric_column = 'iorequests_ps'



-- Current Logons Count
AND m.metric_column like 'logons'

-- Current Open Cursors Count
AND metric_name = 'Database_Resource_Usage' AND metric_column = 'opencursors'

-- Number of Transactions (per second)
and m.metric_name = 'instance_throughput'
AND m.metric_label = 'Throughput'
-- TPS
AND m.metric_column = 'transactions_ps'
-- User Commits
AND m.metric_column = 'commits_ps'


-- Redo generated
AND metric_name = 'instance_throughput'
AND metric_column = 'redosize_pt' --Redo Generated (per transaction)
AND metric_column = 'redosize_ps' --Redo Generated (per second)

-- Average Active Sessions
AND m.metric_name = 'instance_throughput'
AND m.metric_column = 'avg_active_sessions'
AND column_label like 'Average Active Sessions'

-- Database Size
AND m.metric_name ='DATABASE_SIZE' AND (m.metric_column ='ALLOCATED_GB' OR m.metric_column ='USED_GB')
AND m.metric_name ='DATABASE_SIZE' AND m.metric_column ='ALLOCATED_GB'

-- Tablespace Allocated Space (MB)
-- free space in tablespace
AND metric_name LIKE 'problemTbsp'
AND metric_column = 'bytesFree'
AND key_value     = 'MDM'

-- Tablespace Allocated Space (MB)
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column = 'spaceAllocated'
  AND m.metric_label like 'Tablespace Allocation'


-- Network
AND m.metric_name = 'NetworkSummary'
AND m.metric_column = 'totalNetworkThroughPutRate'
AND column_label like 'All Network Interfaces Total I/O Rate (MB/sec)'

-- zaplnena FRA v %
AND METRIC_NAME   = 'ha_flashrecovery'
and metric_column = 'usable_area'
and column_label = 'Usable Flash Recovery Area (%)'

-- server Filesystem Space Available (MB)
AND metric_name = 'Filesystems' AND metric_column = 'available'


--
--
--

SELECT /* OEM metric daily */
   m.*
--   m.target_name,
--   to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "timestamp",
--   m.metric_column, m.column_label,
--   round(m.average,1) average_value
   --round(m.maximum)/1024  maximum_value_gb
   round(m.maximum/1024)  maximum_value_gb
FROM
--  MGMT$METRIC_DAILY m
  MGMT$METRIC_DETAILS m
WHERE  1 = 1
--  AND m.target_name in ('IPCTA')
  AND m.target_name like 'pasbo%'
 -- and m.target_name not like '%.cc.%'  -- nechci Viden
   AND metric_name = 'Filesystems' AND metric_column = 'available'
     and key_value = '/u021'
--AND m.rollup_timestamp > sysdate - interval '3' month
--  order by m.rollup_timestamp asc
 ;


--SELECT max(value)
--  from (
--

SELECT
--    m.*,
  to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss'),
  target_name,
--  key_value,
--  m.metric_column,
--  m.metric_label,
--  m.column_label,
  round(average,2) "Avg Active Sessions"
--  maximum
--  m.maximum value
  --     m.minimum
FROM
  MGMT$METRIC_DAILY m
--  mgmt$metric_daily m
WHERE  1 = 1
  AND m.target_name in ('RTOTI','RTODP','RTOTP','RTODI')
  AND m.metric_name = 'instance_throughput'
  AND m.metric_column = 'avg_active_sessions'
  AND column_label like 'Average Active Sessions'
  AND m.rollup_timestamp > trunc(sysdate-7)
--AND m.target_type IN ( 'rac_database') -- , 'oracle_database'
--AND m.target_type IN ( 'host')
ORDER BY  m.rollup_timestamp
;

--
)
;

--// pouze AIX servery s MEM < 10GB+1 //--
SELECT
  t.target_name,
  h.mem
FROM
  SYSMAN.MGMT_TARGETS t
INNER JOIN mgmt$os_hw_summary h ON   (t.TARGET_GUID = h.target_guid)
WHERE
  t.category_prop_1 = 'AIX'
AND t.target_type   = 'host'
AND mem             < 10241
ORDER BY
  t.target_name ;

-- rollup mgmt$metric_daily
-- usedLogicalMemoryPct
SELECT rollup_timestamp || ';' || listagg (ROUND (value, 2), ';')
               WITHIN GROUP (ORDER BY target_name) as data
from (
--
SELECT
  rollup_timestamp,
  target_name,
  metric_name,
  metric_column,
  column_label,
  average as value
FROM
  mgmt$metric_daily
WHERE
  target_name in (
'eabra01.vs.csin.cz',
'eacps01.vs.csin.cz',
'eadms01.vs.csin.cz',
'eamwcs01.vs.csin.cz',
'earev01.vs.csin.cz',
'inetedu.vs.csin.cz',
'sb4isbo.cc.csin.cz',
'wcmedu.vs.csin.cz',
'wcredu.vs.csin.cz'
)
AND metric_column = 'usedLogicalMemoryPct'
--AND rollup_timestamp = '26.9.2013 0:00'
order by target_name
--
)
WHERE rollup_timestamp > trunc(sysdate - 14)
GROUP BY rollup_timestamp ORDER BY rollup_timestamp;
/