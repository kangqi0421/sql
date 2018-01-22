--
-- HP Monitor
-- view pro kapacitní plánování

-- provést join metriky s MGMT$DB_DBNINSTANCEINFO d

-- grant MGMT_ECM_VIEW to HP_MONITOR;
grant MGMT_USER to HP_MONITOR;

-- tohle by nemělo být třeba, je řešeno přes roli
GRANT SELECT on SYSMAN.MGMT$METRIC_DETAILS to HP_MONITOR;
GRANT SELECT on SYSMAN.MGMT$DB_DBNINSTANCEINFO to HP_MONITOR;
GRANT SELECT on SYSMAN.CM$MGMT_ASM_CLIENT_ECM to HP_MONITOR;

-- aplikační role
INSERT INTO SYSMAN.mgmt_role_grants VALUES ('HP_MONITOR','EM_ALL_VIEWER',0,0);
COMMIT;

## Požadavky kapacitního plánování od HP

--
-- Grafana
--

- EPOCH timestamp
to_char(m.rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIMESTAMP,
(m.rollup_timestamp - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000 * 1000000  AS timestamp

- alias sloupců - velkými písmeny v Node RED


1), 2) tablespace - ANO
 - Zaplnění Oracle Filesystemu
  - Maximální velikost tablespace


#1) udelat jeden pohled pro tablespace, kde je relace database : tablspace = 1 : N
pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

Format timestamp potrebujeme "yyyy-mm-dd hh:mm:ss.ttt" (string)
Format metrik muze byt float

#1) tablespace, kde je relace database : tablspace = 1 : N

pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

## tablespaces metriky
SELECT
   to_char(val.collection_time,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS time,
   d.DATABASE_NAME db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value tablespace,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN MGMT$DB_DBNINSTANCEINFO d ON (m.target_guid = d.target_guid)
WHERE 1=1
  -- AND m.target_name like 'CPTDA'
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column in ('spaceUsed', 'spaceAllocated')
ORDER by 1, 2
;

## DBNAME metriky
- DATABASE_SIZE = dbsize
- nová verze SQL
SELECT
     TO_CHAR(val.collection_time,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS time,
     c.entity_name AS DBNAME,
     c.entity_type,
     p.PROPERTY_VALUE ENV_STATUS,
     k.key_part_1 AS TBS_NAME,
     t.host_name,
     lower(c.metric_column_name) METRIC_NAME,
     c.metric_column_label METRIC_LABEL,
     c.unit,
     sys_op_ceg(val.met_values,c.column_index) AS value
FROM
     sysman.em_metric_items i
     join sysman.gc_metric_columns_target c on i.metric_group_id =
c.metric_group_id
     join sysman.em_metric_values val on i.metric_item_id =
val.metric_item_id
     join sysman.em_metric_keys k on i.metric_key_id = k.metric_key_id
     join sysman.em_targets t on t.target_guid = c.entity_guid
     join sysman.mgmt_target_properties p on p.target_guid = c.entity_guid
WHERE
     c.metric_group_name = 'DATABASE_SIZE'
     AND   p.property_name = 'orcl_gtp_lifecycle_status'
     AND   i.target_guid = c.entity_guid
     AND   c.column_type = 0
     AND   c.data_column_type = 0
     AND   i.last_collection_time = val.collection_time
     AND   c.entity_guid NOT IN (
         SELECT
             dest_me_guid
         FROM
             sysman.gc$assoc_instances a
         WHERE
             a.assoc_type = 'cluster_contains'
     )
ORDER BY time, dbname, env_status, metric_name;

--

## INSTANCE metriky
SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
   m.target_guid,
   d.DATABASE_NAME db_name,
   d.instance_name instance_name,
   m.metric_column, m.column_label,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN MGMT$DB_DBNINSTANCEINFO d
    ON (m.target_guid = d.target_guid
    AND m.target_name = d.target_name)
WHERE 1=1
  -- AND m.target_name like 'CPTDA'
  -- AND d.database_name like 'MCIZ'
  AND m.metric_name in
    ('DATABASE_SIZE', 'Database_Resource_Usage', 'instance_efficiency',
     'memory_usage', 'instance_throughput')
  AND m.metric_column in
    ('ALLOCATED_GB', 'logons', 'cpuusage_ps', 'total_memory', 'iorequests_ps')
;

## ASM metriky



-- Grafana
SELECT
    TO_CHAR(val.collection_time,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS time,
    c.entity_name AS ASM_INSTANCE_NAME,
    k.key_part_1 AS ASM_GROUP_NAME,
    t.host_name,
    p.PROPERTY_VALUE ENV_STATUS,
    lower(c.metric_column_name) METRIC_NAME,
    c.metric_column_label METRIC_LABEL,
    'MB' as unit,
    sys_op_ceg(val.met_values,c.column_index) AS value
FROM
    sysman.em_metric_items i,
    sysman.gc_metric_columns_target c,
    sysman.em_metric_values val,
    sysman.em_metric_keys k,
    sysman.gc$target t,
    sysman.MGMT_TARGET_PROPERTIES p
WHERE
    i.metric_group_id = c.metric_group_id
    AND   i.target_guid = c.entity_guid
    AND   t.target_guid = c.entity_guid
    AND   i.metric_item_id = val.metric_item_id
    AND   i.metric_key_id = k.metric_key_id
    AND   c.column_type = 0
    AND   c.data_column_type = 0
    AND   p.target_guid = c.entity_guid
    AND   p.property_name = 'orcl_gtp_lifecycle_status'
    and   c.metric_group_name = 'DiskGroup_Usage'
    AND   c.metric_column_name in (
      'usable_file_mb',  -- Disk Group Usable Free (MB)
      'total_mb')        -- Size (MB)
    AND   i.last_collection_time = val.collection_time
    AND p.PROPERTY_VALUE is not NULL
ORDER BY
    time, ASM_INSTANCE_NAME, ASM_GROUP_NAME, METRIC_NAME
;

-- ASM metriky
-- LEFT join na DB_NAME, který není vždy uveden
SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
   a.db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value diskgroup,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  LEFT JOIN CM$MGMT_ASM_CLIENT_ECM a
    on (m.target_guid = a.cm_target_guid AND m.target_name = a.cm_target_name
    AND m.key_value   = a.diskgroup)
WHERE 1=1
--      AND a.db_name like 'CPTDA'
--    AND key_value like 'RTOZA_%'
    AND m.metric_name = 'DiskGroup_Usage'
    -- and   c.metric_group_name = 'DiskGroup_Usage'
    AND metric_column in (
      'usable_file_mb',  -- Disk Group Usable Free (MB)
      'total_mb')        -- Size (MB)
;

## OEM CPU MEMORY IO

SELECT
    to_char(m.rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIMESTAMP,
    d.database_name DBNAME,
    d.instance_name,
    d.host_name,
    p.PROPERTY_VALUE ENV_STATUS,
    lower(m.metric_column) as METRIC_NAME,
    m.column_label as METRIC_LABEL,
    round(m.average, 2) as AVG,
    round(m.minimum, 2) as MIN,
    round(m.maximum, 2) as MAX,
    case
      when m.metric_column = 'cpuusage_ps' then 'cpu'
      when m.metric_column = 'total_memory' then 'memory'
      when m.metric_column = 'sga_total' then 'memory'
      when m.metric_column = 'pga_total' then 'memory'
      when m.metric_column = 'iombs_ps' then 'io'
      when m.metric_column = 'iorequests_ps' then 'io'
    else 'other' end as METRIC_TYPE
FROM
    sysman.MGMT$METRIC_DAILY m
    JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
    join sysman.MGMT_TARGET_PROPERTIES p on (p.target_guid = d.target_guid)
WHERE 1=1
  AND   p.property_name = 'orcl_gtp_lifecycle_status'
  AND   p.property_value is not NULL
  AND   m.metric_name in (
           'instance_efficiency', 'memory_usage', 'memory_usage_sga_pga', 'instance_throughput')
  AND   m.metric_column in (
           'cpuusage_ps', 'total_memory', 'sga_total', 'pga_total', 'iorequests_ps', 'iombs_ps')
  AND   m.rollup_timestamp > sysdate - interval '3' day
  AND   d.database_name LIKE 'MCIZ%'
ORDER BY timestamp, dbname, env_status, metric_name



## Stat 12c SYSMETRIC

select
 to_char(end_time, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
 case when d.CON_ID=0 then d.DBID else d.CON_DBID end as DBID,
 d.NAME,
 m.CON_ID,
 -- 11.2-- 0 as CON_ID,
 i.INSTANCE_NAME,
 i.HOST_NAME,
 m.METRIC_NAME as METRIC_NAME,
 m.METRIC_UNIT,
 round(m.value,3) as AVG,
 case when METRIC_NAME = 'Database Time Per Sec' then 'response_time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'response_time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'response_time'
      when METRIC_NAME =  'SQL Service Response Time' then 'response_time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'cpu'
      when METRIC_NAME = 'Host CPU Utilization (%)' then 'cpu'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'redo'
      when METRIC_NAME = 'Session Count' then 'session'
      when METRIC_NAME = 'Logons Per Sec' then 'session'
      when METRIC_NAME = 'User Commits Per Sec' then 'transactions'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'transactions'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'io'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'io'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'io'
      when METRIC_NAME = 'Current Open Cursors Count' then 'cursors'
      when METRIC_NAME = 'Total PGA Allocated' then 'memory'
      when METRIC_NAME = 'Total PGA Used by SQL Workareas' then 'memory'
      when METRIC_NAME = 'Temp Space Used' then 'memory'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'memory'
      when METRIC_NAME = 'I/O Requests per Second' then 'io'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'io'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'pq'
     else 'other' end as METRIC_TYPE,
 case when METRIC_NAME = 'Database Time Per Sec' then 'Database_Time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'Database_CPU_Time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'Database_Wait_Time'
      when METRIC_NAME = 'SQL Service Response Time' then 'SQL_Service_Response_Time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'CPU_Usage'
      when METRIC_NAME = 'Host CPU Utilization (%)' then 'Host_CPU_Utilization'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'Redo_Generated'
      when METRIC_NAME = 'Session Count' then 'Session_Count'
      when METRIC_NAME = 'Logons Per Sec' then 'Logons'
      when METRIC_NAME = 'User Commits Per Sec' then 'User_Commits'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'User_Rollbacks'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'Logical_Reads'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'Total_Table_Scans'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'Full_Index_Scans'
      when METRIC_NAME = 'Current Open Cursors Count' then 'Current_Open_Cursors'
      when METRIC_NAME = 'Total PGA Allocated' then 'Total_PGA_Allocated'
      when METRIC_NAME = 'Total PGA Used by SQL Workareas' then 'Total_PGA_Used'
      when METRIC_NAME = 'Temp Space Used' then 'Temp_Space_Used'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'Disk_Sort'
      when METRIC_NAME = 'I/O Requests per Second' then 'IO_Requests'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'IO_Megabytes'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'Total_Parse'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'Hard_Parse'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'Hard_Parse'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'Queries_parallelized'
     else 'other' end as METRIC
from
 V$SYSMETRIC m, V$INSTANCE i, V$DATABASE d
where
 d.CON_ID = i.CON_ID
 AND i.CON_ID = m.CON_ID
 and m.group_id = 2
 AND m.INTSIZE_CSEC>5000 and m.BEGIN_TIME>(sysdate-1/24/60*3)
 and m.METRIC_NAME in (
    'Database Time Per Sec',
    'Database CPU Time Ratio',
    'Database Wait Time Ratio',
    'SQL Service Response Time',
    'CPU Usage Per Sec',
    'Host CPU Utilization (%)',
    'Redo Generated Per Sec',
    'Session Count',
    'Logons Per Sec',
    'User Commits Per Sec',
    'User Rollbacks Per Sec',
    'Logical Reads Per Sec',
    'Total Table Scans Per Sec',
    'Full Index Scans Per Sec',
    'Current Open Cursors Count',
    'Total PGA Allocated',
    'Total PGA Used by SQL Workareas',
    'Temp Space Used',
    'Disk Sort Per Sec',
    'I/O Requests per Second',
    'I/O Megabytes per Second',
    'Total Parse Count Per Sec',
    'Hard Parse Count Per Sec',
    'Queries parallelized Per Sec')
order by METRIC_NAME,METRIC_UNIT,CON_ID

-- puvodni verze od Vitka

msg.topic = 'stat';
msg.query = `select
 to_char(max(DATUM),'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
 min(DBID) as DBID,
 min(NAME) as DBNAME,
 CON_ID,
 min(INSTANCE_NAME) as INSTANCE_NAME,
 min(HOST_NAME) as HOST_NAME,
 METRIC_NAME,
 METRIC_UNIT,
 round(avg(value),3) as AVG,
 round(min(value),3) as MIN,
 round(max(value),3) as MAX,
 case when METRIC_NAME = 'Database Time Per Sec' then 'response_time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'response_time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'response_time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'cpu'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'redo'
      when METRIC_NAME = 'Session Count' then 'session'
      when METRIC_NAME = 'Logons Per Sec' then 'session'
      when METRIC_NAME = 'User Commits Per Sec' then 'transactions'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'transactions'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'io'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'io'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'io'
      when METRIC_NAME = 'Current Open Cursors Count' then 'cursors'
      when METRIC_NAME = 'Total PGA Allocated' then 'memory'
      when METRIC_NAME = 'Total PGA Used by SQL Workareas' then 'memory'
      when METRIC_NAME = 'Temp Space Used' then 'memory'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'memory'
      when METRIC_NAME = 'I/O Requests per Second' then 'io'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'io'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'pq'
     else 'other' end as METRIC_TYPE,
 case when METRIC_NAME = 'Database Time Per Sec' then 'Database_Time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'Database_CPU_Time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'Database_Wait_Time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'CPU_Usage'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'Redo_Generated'
      when METRIC_NAME = 'Session Count' then 'Session_Count'
      when METRIC_NAME = 'Logons Per Sec' then 'Logons'
      when METRIC_NAME = 'User Commits Per Sec' then 'User_Commits'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'User_Rollbacks'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'Logical_Reads'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'Total_Table_Scans'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'Full_Index_Scans'
      when METRIC_NAME = 'Current Open Cursors Count' then 'Current_Open_Cursors'
      when METRIC_NAME = 'Total PGA Allocated' then 'Total_PGA_Allocated'
      when METRIC_NAME = 'Total PGA Used by SQL Workareas' then 'Total_PGA_Used'
      when METRIC_NAME = 'Temp Space Used' then 'Temp_Space_Used'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'Disk_Sort'
      when METRIC_NAME = 'I/O Requests per Second' then 'IO_Requests'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'IO_Megabytes'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'Total_Parse'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'Hard_Parse'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'Hard_Parse'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'Queries_parallelized'
     else 'other' end as METRIC
from
(
select
 END_TIME as DATUM,
 case when d.CON_ID=0 then d.DBID else d.CON_DBID end as DBID,
 d.NAME,
 m.CON_ID,
 i.INSTANCE_NAME,
 i.HOST_NAME,
 m.METRIC_NAME as METRIC_NAME,
 m.METRIC_UNIT,
 m.value
from
 V$SYSMETRIC_HISTORY m, V$INSTANCE i, V$DATABASE d
where
 d.CON_ID = i.CON_ID and
 i.CON_ID = m.CON_ID and
 m.INTSIZE_CSEC>5000 and m.BEGIN_TIME>(sysdate-1/24/60*3) and
 m.METRIC_NAME in (
'Database Time Per Sec',
'Database CPU Time Ratio',
'Database Wait Time Ratio',
'CPU Usage Per Sec',
'Redo Generated Per Sec',
'Session Count',
'Logons Per Sec',
'User Commits Per Sec',
'User Rollbacks Per Sec',
'Logical Reads Per Sec',
'Total Table Scans Per Sec',
'Full Index Scans Per Sec',
'Current Open Cursors Count',
'Total PGA Allocated',
'Total PGA Used by SQL Workareas',
'Temp Space Used',
'Disk Sort Per Sec',
'I/O Requests per Second',
'I/O Megabytes per Second',
'Total Parse Count Per Sec',
'Hard Parse Count Per Sec',
'Queries parallelized Per Sec')
)
group by METRIC_NAME,METRIC_UNIT,CON_ID
order by METRIC_NAME,METRIC_UNIT,CON_ID`;
return msg;


## Wait Class

- unit: Active_Sessions
- union s CPU pro zobrazení jako ASH data

select
    to_char(END_TIME, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
    d.dbid,
    d.name as dbname,
    m.CON_ID,
    INSTANCE_NAME,
    HOST_NAME,
    RT_CLASS,
    'average_active_sessions' as METRIC_UNIT,
    AAS as AVG,
    'rt_class' as METRIC_TYPE
from (
select
  m.END_TIME,
  m.CON_ID,
  replace(n.WAIT_CLASS,' ','_') as RT_CLASS,
  round(m.time_waited/m.INTSIZE_CSEC,3) AAS
 from
  v$waitclassmetric m inner join v$system_wait_class n on m.wait_class_id=n.wait_class_id
 where n.wait_class != 'Idle'
union
select END_TIME, m.CON_ID, 'CPU', round(value/100,3) AAS
 from v$sysmetric m where metric_name='CPU Usage Per Sec' and group_id=2
) m, V$INSTANCE i, V$DATABASE d
order by RT_CLASS,CON_ID
;




## Wait event metriky

- lepší sbírat online na úrovni direct DB
select
 to_char(max(DATUM),'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
 min(DBID) as DBID,
 min(NAME) as DBNAME,
 CON_ID,
 min(INSTANCE_NAME) as INSTANCE_NAME,
 min(HOST_NAME) as HOST_NAME,
 METRIC,
 METRIC_UNIT,
 round(avg(TIME_WAITED_FG),0) as TIME_WAITED_FG,
 round(avg(WAIT_COUNT_FG),0) as WAIT_COUNT_FG,
 round(avg(AVG_WAIT),3) as AVG_WAIT,
 'wait' as METRIC_TYPE
from
(
select
 END_TIME as DATUM,
 case when d.CON_ID=0 then d.DBID else d.CON_DBID end as DBID,
 d.NAME,
 m.CON_ID,
 i.INSTANCE_NAME,
 i.HOST_NAME,
 replace(e.NAME,' ','_') METRIC,
 'millisecond' as METRIC_UNIT,
 m.TIME_WAITED_FG*10 as TIME_WAITED_FG,
 m.WAIT_COUNT_FG,
 case when m.WAIT_COUNT_FG<>0 then m.TIME_WAITED_FG/m.WAIT_COUNT_FG*10 else 0
end  as AVG_WAIT
from
 V$EVENTMETRIC m, V$EVENT_NAME e, V$INSTANCE i, V$DATABASE d
where
   d.CON_ID = i.CON_ID and
   i.CON_ID = m.CON_ID and
   m.INTSIZE_CSEC>5000 and m.BEGIN_TIME>(sysdate-1/24/60*3) and
   m.EVENT_ID = e.EVENT_ID and
   e.NAME in (
      'log file parallel write',
      'log file sync',
      'db file scattered read',
      'db file sequential read',
      'resmgr:cpu quantum')
)
group by METRIC,METRIC_UNIT,CON_ID
order by METRIC,METRIC_UNIT,CON_ID


- EM
SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
   d.DATABASE_NAME db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value wait_event,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN MGMT$DB_DBNINSTANCEINFO d ON (m.target_guid = d.target_guid)
WHERE 1=1
  -- AND m.target_name like 'CPTDA'
  AND m.metric_name = 'topWaitEvents'
  AND m.metric_column = 'averageWaitTime'
  AND column_label like 'Average Wait Time (millisecond)'
  AND key_value in ('log file sync', 'log file parallel write', 'direct path read temp',
                    'control file sequential read', 'direct path read',
                    'db file scattered read', 'db file sequential read')
;


2a) - Zaplnění tablespace = velikost databáze - ANO

OEM metriky:
m.metric_name ='DATABASE_SIZE' AND m.metric_column ='ALLOCATED_GB'

2b) ASM metriky - ANO

velikost ASM diskgroupy a zaplnění ASM diskgroupy

OEM metriky:
ASM Disk Group Usage
- Disk Group Usable (MB)
- Size (MB)

m.metric_name ='DATABASE_SIZE' AND m.metric_column ='ALLOCATED_GB'



3) Počet otevřených sessions v DB - ANO

OEM metriky:
 m.metric_column like 'logons'


4) čtení - IO latence single bloku [ms] - NE

Latence IO bloku je lepší sledovat na úrovni OS nebo úrovni SAN pole

5) zápis - log file sync - ANO

SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
   d.DATABASE_NAME db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value wait_event,
   m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN MGMT$DB_DBNINSTANCEINFO d ON (m.target_guid = d.target_guid)
WHERE 1=1
  -- AND m.target_name like 'CPTDA'
  AND m.metric_name = 'topWaitEvents'
  AND m.metric_column = 'averageWaitTime'
  AND column_label like 'Average Wait Time (millisecond)'
  AND key_value in ('log file sync', 'log file parallel write',
                    'db file scattered read', 'db file sequential read')
;

6)Average Wait Time - NE

average wait čeho ? Hodnota Average Wait je vám bez konkrétní oracle metriky z pohledu kapacitního plánování k ničemu.

7) Zaplnění Oracle Filesystemu - NE, pokrývají již body 1) a 2)

8)  Kolik DB pro konkrétní aplikaci spotřebovává CPU a RAM - ANO

Poměr CPU spotřeby a velikost MEM per databáze lze v OEM sledovat. Jedná se ale pouze o poměr a tedy pouze relativní čísla. Pro kapa

OEM CPU DB:
metric_name = 'instance_efficiency' AND metric_column = 'cpuusage_ps'

OEM MEM DB:
AND m.metric_name = 'memory_usage' AND m.metric_column = 'total_memory'


9)  IOPSy co produkují naše db - ANO

OEM:
m.metric_name = 'instance_throughput' AND m.metric_column = 'iorequests_ps'