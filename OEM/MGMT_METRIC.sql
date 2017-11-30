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

-- MGMT / CM metriky
select * from dba_objects
  where object_name like 'CM$MGMT%'
  like 'MGMT$DB_%'
and owner = 'SYSMAN'
;


-- HW metriky
CM$MGMT_ECM_HW
CM$MGMT_ECM_HW_VIRTUAL
MGMT$OS_HW_SUMMARY
MGMT$HW_CPU_DETAILS

-- BACKUP
MGMT$HA_BACKUP

-- CM Configuration metriky
CM$MGMT_ASM_CLIENT_ECM

-- CPU instance caging
MGMT$DB_CPU_USAGE  -- per instance


-- DB users - hodilo by se pro REDIM ?
MGMT$DB_USERS

-- cluster services
CM$MGMT_CLUSTER_ACTV_SRVS_ECM

-- cluster scan adress
CM$MGMT_CLUSTER_CONFIG


select * from dba_views
  where view_name like 'CM$%ASM%'
  where view_name like 'MGMT$%ASM%'
order by view_name
;

select metric_item_id
      ,collection_time
      ,met_values
  from em_metric_values
 where rownum < 11;

-- retention periods
select table_name, partitions_retained
from SYSMAN.em_int_partitioned_tables
where table_name in ('EM_METRIC_VALUES','EM_METRIC_VALUES_HOURLY','EM_METRIC_VALUES_DAILY');



-- hledani metriky
-- zaměnit za sysman.mgmt_metrics ?

select distinct metric_name, metric_column, metric_label, column_label
  from mgmt$metric_current
 where
   --metric_name like '%pga%'  '%Network%' 'Redo%'
   column_label like '%Filesystem%'
   --metric_column like 'cursors'
  -- AND target_name like 'pasbo%'
    AND target_name like 'CPTDA'
;


-- CPU util server
AND metric_name = 'Load' AND metric_column = 'cpuUtil'

-- CPU util v DB
AND m.metric_name = 'instance_efficiency' AND m.metric_column = 'cpuusage_ps'
AND metric_name = 'wait_bottlenecks' AND metric_column = 'user_cpu_time_cnt'

-- CPU res mgr
-- m.average
  AND m.metric_name = 'topWaitEvents'  AND m.metric_column = 'totalWaitTime'
  AND key_value like 'resmgr:cpu quantum'


-- Memory util server
AND metric_name = 'Load'
 -- neukazuje spravne s HugePages AND metric_column = 'memUsedPct'
-- pro AIX: Used Logical Memory (%)
metric_column = 'usedLogicalMemoryPct'

-- SGA a PGA Total Memory [MB]
-- pohybuje se v čase
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

-- Log File Sync
-- Wait Event
  AND m.metric_name = 'topWaitEvents'
  AND m.metric_column = 'averageWaitTime'
  AND column_label like 'Average Wait Time (millisecond)'
AND key_value     = 'log file sync'
-- AND key_value     = 'db file sequential read'  AND m.metric_name = 'topWaitEvents'
  AND m.metric_column = 'averageWaitTime'
  AND column_label like 'Average Wait Time (millisecond)'
  AND key_value in ('log file sync', 'log file parallel write', 'direct path read temp',
                    'control file sequential read', 'direct path read',
                    'db file scattered read', 'db file sequential read')


-- Current Logons Count
AND  m.metric_name = 'Database_Resource_Usage' AND m.metric_column like 'logons'
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
-- This metric represents the amount of redo, in bytes, generated per second during this sample period.
AND metric_column = 'redosize_ps' --Redo Generated (per second)

-- Average Active Sessions
AND m.metric_name = 'instance_throughput'
AND m.metric_column = 'avg_active_sessions'
AND column_label like 'Average Active Sessions'

-- Database Size
AND m.metric_name ='DATABASE_SIZE' AND (m.metric_column ='ALLOCATED_GB' OR m.metric_column ='USED_GB')
AND m.metric_name ='DATABASE_SIZE' AND m.metric_column ='ALLOCATED_GB'


-- Tablespace Allocated Space (MB)
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column = 'spaceAllocated'
  AND m.column_label = 'Tablespace Allocated Space (MB)'

--  Tablespace Used Space (MB)
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column = 'spaceUsed'
  AND m.column_label = 'Tablespace Allocated Space (MB)'


-- free space in tablespace
AND metric_name LIKE 'problemTbsp'
AND metric_column = 'bytesFree'
AND key_value     = 'MDM'

-- mgmt$db_tablespaces
SELECT
         ROUND(SUM(t.tablespace_size/1024/1024/1024), 2) AS ALLOC_GB,
         ROUND(SUM(t.tablespace_used_size/1024/1024/1024), 2) AS USED_GB,
         ROUND(SUM((t.tablespace_size - tablespace_used_size)/1024/1024/1024), 2) AS ALLOC_FREE_GB
       FROM
         mgmt$db_tablespaces t,
         (SELECT target_guid
            FROM mgmt$target
            WHERE target_guid=HEXTORAW(??EMIP_BIND_TARGET_GUID??) AND
            (target_type='rac_database' OR
            (target_type='oracle_database' AND TYPE_QUALIFIER3 != 'RACINST'))) tg
       WHERE
         t.target_guid=tg.target_guid

-- ASM diskgroup
Disk Group Usage
- Disk Group Usable (MB)
- Size (MB)


-- Disk Group Usable Free (MB)
AND m.metric_name = 'DiskGroup_Usage'
AND metric_column in ('usable_file_mb',  -- Disk Group Usable (MB)
                      'total_mb')        -- Size (MB)

-- Network
AND m.metric_name = 'NetworkSummary'
AND m.metric_column = 'totalNetworkThroughPutRate'
AND column_label like 'All Network Interfaces Total I/O Rate (MB/sec)'

-- zaplnena FRA v %
AND METRIC_NAME   = 'ha_flashrecovery'
and metric_column = 'flash_recovery_area_size'
and metric_column = 'usable_area'

-- server Filesystem Space Available (MB)
AND metric_name = 'Filesystems' AND metric_column = 'available'


--
--
--

SELECT
   m.*
--   m.target_name,
--   to_char(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "timestamp",
--   m.metric_column, m.column_label,
--   round(m.average,1) average_value
   --round(m.maximum)/1024  maximum_value_gb
FROM
--  MGMT$METRIC_DAILY m
  MGMT$METRIC_DETAILS m
    -- JOIN pro databázové targety
    -- JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE  1 = 1
  AND m.target_name like 'IPCTA%'
  -- AND m.target_name like 'pasbo%'
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