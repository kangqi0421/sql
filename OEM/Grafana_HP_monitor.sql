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

-- tohle je explicitně potřeba
GRANT SELECT on SYSMAN.MGMT_ASM_DISK_ECM to HP_MONITOR;

-- aplikační role
INSERT INTO SYSMAN.MGMT_ROLE_GRANTS VALUES ('HP_MONITOR','EM_ALL_VIEWER',0,0);
COMMIT;

--
-- Grafana
--

- EPOCH timestamp
to_char(m.rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIMESTAMP,
(m.rollup_timestamp - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000 * 1000000  AS timestamp

- alias sloupců - velkými písmeny v Node RED


-- udelat jeden pohled pro tablespace, kde je relace database : tablspace = 1 : N
pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

Format timestamp potrebujeme "yyyy-mm-dd hh:mm:ss.ttt" (string)
Format metrik muze byt float

-- tablespace, kde je relace database : tablspace = 1 : N

pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

1) tablespaces metriky

- pouze aktuální data bez historie

```
// pouze aktualni hodnoty bez historie
msg.payload = [];
msg.topic = 'tbs';
msg.query = `
select
     TO_CHAR(t.collection_timestamp,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS TIMESTAMP,
     d.database_name as DBNAME,
     d.host_name,
     p.PROPERTY_VALUE ENV_STATUS,
     tablespace_name,
     round(tablespace_size/power(1024,2)) as SIZE_MB,
     round(tablespace_used_size/power(1024,2)) AS USED_MB,
     'MB' as UNIT
  from    sysman.mgmt$db_tablespaces t
     JOIN sysman.mgmt$db_dbninstanceinfo d ON (t.target_guid = d.target_guid)
     JOIN sysman.mgmt_target_properties p ON (p.target_guid = d.target_guid)
 where p.property_name = 'orcl_gtp_lifecycle_status'
   AND t.collection_timestamp > sysdate - interval '${context.global.params.oem_collection_date}' day
   -- AND d.database_name = 'PDBP' and tablespace_name = 'SYSTEM'
ORDER BY TIMESTAMP, DBNAME, HOST_NAME, TABLESPACE_NAME
`;
return msg;
```

```
var res = [];
var tagNames = ["DBNAME", "TABLESPACE_NAME", "HOST_NAME", "ENV_STATUS", "UNIT"];
for (var p in msg.payload) {
    var m = msg.payload[p];

    var vals = {};
    vals['size_mb'] = m.SIZE_MB;
    vals['used_mb'] = m.USED_MB;

    // tags
    var tags = {};
    for (var i in tagNames) {
        tags[tagNames[i].toLowerCase()] = m[tagNames[i]];
    }

    //additional computations
    /*
    var bytesFree = vals['bytesfree'];
    var pctUsed = vals['pctused'];
    if (pctUsed != 100) {
        vals['occupied'] = Math.round(bytesFree/(100-pctUsed)*pctUsed);
        vals['maxsize'] = Math.round(100/(100-pctUsed)*bytesFree);
    }
    vals['bytesfree'] = Math.round(vals['bytesfree']);
    vals['pctused'] = Number(vals['pctused'].toFixed(2));
    */

    res.push({
        measurement: 'tablespace_1d',
        fields: vals,
        tags: tags,
        timestamp: new Date(m.TIMESTAMP)
    });
}
msg.payload = res;
return msg;
```


2) database size

- pouze daily aggregace, hourly neexistují

// daily agg
msg.payload = [];
msg.topic = 'size';
msg.query = `
WITH DB_METRIC
AS (
  SELECT
   rollup_timestamp,
   target_guid,
   METRIC_COLUMN,
   ROUND(AVERAGE) VALUE
 FROM
        SYSMAN.MGMT$METRIC_DAILY
 WHERE
       METRIC_NAME    = 'DATABASE_SIZE'
   AND METRIC_COLUMN in ('ALLOCATED_GB', 'USED_GB')
)
SELECT
   to_char(rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as TIMESTAMP,
   d.database_name DBNAME,
   t.host_name as HOST_NAME,
   p.property_value ENV_STATUS,
   ALLOCATED_GB,
   USED_GB
FROM DB_METRIC
    PIVOT (MIN(VALUE) FOR METRIC_COLUMN IN (
        'ALLOCATED_GB' AS ALLOCATED_GB,
        'USED_GB' AS USED_GB)
          ) m
    JOIN sysman.MGMT$TARGET t
      ON (m.target_guid = t.target_guid)
    JOIN sysman.mgmt$db_dbninstanceinfo d ON (t.target_guid = d.target_guid)
    JOIN sysman.MGMT_TARGET_PROPERTIES p
      ON (p.target_guid = m.target_guid)
WHERE
       p.property_name = 'orcl_gtp_lifecycle_status'
  AND  p.property_value is not NULL
  AND  m.rollup_timestamp > sysdate - interval '${context.global.params.oem_collection_date}' DAY
  -- AND  d.database_name = 'PDBP'
ORDER BY
    TIMESTAMP, DBNAME, HOST_NAME
`;
return msg;


```
// daily agg
var res = [];
var tagNames = ['DBNAME', 'HOST_NAME', 'ENV_STATUS'];
for (var p in msg.payload) {
    var m = msg.payload[p];

    var vals = {};
    vals['allocated_gb'] = m.ALLOCATED_GB;
    vals['used_gb'] = m.USED_GB;

    var tags = {};
    for (var i in tagNames) {
         tags[tagNames[i].toLowerCase()] = m[tagNames[i]];
    }

    res.push({
        measurement: 'dbsize_1d',
        fields: vals,
        tags: tags,
        timestamp: new Date(m.TIMESTAMP)
    });
}
msg.payload = res;
return msg;
```


3) ASM metriky

- pouze daiy aggregace, hourly sice neexistují, ale sjednoceno s velikostí DB

// daily agg
msg.payload = [];
msg.topic = 'asm';
msg.query = `
WITH ASM_METRIC
AS (
  SELECT
   rollup_timestamp,
   target_guid,
   key_value as ASM_GROUP_NAME,
   METRIC_COLUMN,
   ROUND(AVERAGE) VALUE
FROM
    SYSMAN.MGMT$METRIC_DAILY
WHERE
  target_type like 'osm%'
  AND METRIC_NAME = 'DiskGroup_Usage'
  AND METRIC_COLUMN in ('usable_file_mb',  -- Disk Group Usable (MB)
                          'total_mb',        -- Size (MB)
                          'percent_used'     -- Percent Used
                          )
)
select
   to_char(rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as TIMESTAMP,
   dg.DB_NAME as DBNAME,
   t.host_name as HOST_NAME,
   ASM_GROUP_NAME,
   p.property_value ENV_STATUS,
   FREE_MB,
   TOTAL_MB,
   PERCENT_USED
  FROM ASM_METRIC
    PIVOT (MIN(VALUE) FOR METRIC_COLUMN IN (
        'usable_file_mb' AS FREE_MB,
        'total_mb' AS TOTAL_MB,
        'percent_used' AS PERCENT_USED)
          ) m
    JOIN MGMT$TARGET t ON (m.target_guid = t.target_guid)
    JOIN sysman.MGMT_TARGET_PROPERTIES p
      ON (p.target_guid = m.target_guid)
    LEFT JOIN (
      select distinct DISKGROUP, DB_NAME from SYSMAN.MGMT_ASM_CLIENT_ECM
        ) dg on (dg.diskgroup = m.ASM_GROUP_NAME)
WHERE
       p.property_name = 'orcl_gtp_lifecycle_status'
  AND  p.PROPERTY_VALUE is not NULL
  AND  m.rollup_timestamp > sysdate - interval '2' DAY
  -- AND  dg.DB_NAME = 'MCIP' and m.ASM_GROUP_NAME = 'MCIP_D01'
ORDER BY
    TIMESTAMP, DBNAME, ASM_GROUP_NAME
`;
return msg;


-- transform ASM
var res = [];
var tagNames = ["DBNAME", "ASM_GROUP_NAME", "HOST_NAME", "ENV_STATUS"];
for (var p in msg.payload) {
    var m = msg.payload[p];

    var vals = {};
    vals['size_mb'] = m.TOTAL_MB;
    vals['free_mb'] = m.FREE_MB;
    vals['percent_used'] = m.PERCENT_USED;

    var tags = {};
    for (var i in tagNames) {
         tags[tagNames[i].toLowerCase()] = m[tagNames[i]];
    }

    // calculated values
    var totalSize = vals['size_mb'];
    var freeSize  = vals['free_mb'];

    vals['used_mb'] = Math.round(totalSize - freeSize)

    res.push({
        measurement: 'asm_1d',
        fields: vals,
        tags: tags,
        timestamp: new Date(m.TIMESTAMP)
    });
}
msg.payload = res;
return msg;



4) DB INSTANCE metriky: CPU, MEM, IO, Transactions

msg.payload = [];
msg.topic = 'cpu';
msg.query = `
SELECT
    to_char(m.rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as TIMESTAMP,
    d.database_name DBNAME,
    d.instance_name INSTANCE_NAME,
    d.host_name HOST_NAME,
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
      when m.metric_column = 'redosize_ps' then 'redo'
      when m.metric_column = 'transactions_ps' then 'transactions'
      when m.metric_column = 'logons' then 'session'
      when m.metric_column = 'opencursors' then 'cursors'
    else 'other' end as METRIC_TYPE
FROM
    SYSMAN.MGMT$METRIC_DAILY m
    JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
    join SYSMAN.MGMT_TARGET_PROPERTIES p on (p.target_guid = d.target_guid)
WHERE 1=1
  AND   p.property_name = 'orcl_gtp_lifecycle_status'
  AND   p.property_value is not NULL
  AND   m.metric_name in (
           'instance_efficiency', 'memory_usage', 'memory_usage_sga_pga', 'instance_throughput','Database_Resource_Usage')
  AND   m.metric_column in (
           'cpuusage_ps',
           'total_memory', 'sga_total', 'pga_total',
           'iorequests_ps', 'iombs_ps',
           'redosize_ps',
           'transactions_ps', 'logons', 'opencursors')
  AND   m.rollup_timestamp > sysdate - interval '2' day
  AND   m.average is NOT NULL
  -- AND   d.database_name LIKE 'MDWZ'
ORDER BY timestamp, dbname, instance_name, host_name, metric_name
`;
return msg;

var res = [];
var tagNames = ['DBNAME', 'INSTANCE_NAME', 'HOST_NAME', 'ENV_STATUS',];
for (var p in msg.payload) {
    var m = msg.payload[p];

    var vals = {};
    vals[m.METRIC_NAME + '_' + 'avg'] = Math.round(m.AVG*100)/100;
    vals[m.METRIC_NAME + '_' + 'min'] = Math.round(m.MIN*100)/100;
    vals[m.METRIC_NAME + '_' + 'max'] = Math.round(m.MAX*100)/100;

    var tags = {};
    for (var i in tagNames) {
         tags[tagNames[i].toLowerCase()] = m[tagNames[i]];
    }

    res.push({
        measurement: m.METRIC_TYPE + '_1d',
        fields: vals,
        tags: tags,
        timestamp: new Date(m.TIMESTAMP)
    });
}
msg.payload = res;
return msg;


5) server OS metriky

// daily agg
msg.payload = [];
msg.topic = 'server';
msg.query = `
WITH SERVER_METRIC
AS (
  SELECT
   rollup_timestamp,
   m.target_guid,
   METRIC_COLUMN,
   ROUND(AVERAGE, 2) VALUE
 FROM
    SYSMAN.MGMT$METRIC_DAILY m
WHERE
  m.target_type like 'host'
  AND m.metric_name in ('Load', 'DiskActivitySummary')
  AND m.metric_column in (
        'cpuUtil',
        'usedLogicalMemoryPct',
        'totiosmade',
        'maxavserv')
)
select
   to_char(rollup_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as TIMESTAMP,
   s.host_name as HOST_NAME,
   p.property_value ENV_STATUS,
   decode(s.virtual, 'Yes', 'true', 'No', 'false') virtual,
   total_cpu_cores CPU_CORES,
   NVL(CPU_UTIL, 0) CPU_UTIL,
   NVL(MEMORY_UTIL, 0) MEMORY_UTIL,
   NVL(IOPS, 0) IOPS,
   NVL(AVG_SRV_TIME, 0) AVG_SRV_TIME
  FROM SERVER_METRIC
    PIVOT (MIN(VALUE) FOR METRIC_COLUMN IN (
        'cpuUtil' AS cpu_util,
        'usedLogicalMemoryPct' AS memory_util,
        'totiosmade' AS iops,
        'maxavserv' avg_srv_time)
          ) m
    JOIN MGMT$OS_HW_SUMMARY s
      ON (m.target_guid = s.target_guid)
    JOIN sysman.MGMT_TARGET_PROPERTIES p
      ON (p.target_guid = m.target_guid)
WHERE
       p.property_name = 'orcl_gtp_lifecycle_status'
  AND  p.PROPERTY_VALUE is not NULL
  AND  m.rollup_timestamp > sysdate - interval '2' DAY
  -- AND  host_name = 'tordb02.vs.csin.cz'
ORDER BY
    TIMESTAMP, HOST_NAME
`;
return msg;


// daily agg
var res = [];
var tagNames = ['HOST_NAME', 'ENV_STATUS', 'VIRTUAL'];
for (var p in msg.payload) {
    var m = msg.payload[p];

    var vals = {};
    vals['cpu_cores'] = m.CPU_CORES;
    vals['cpu_util'] = m.CPU_UTIL;
    vals['memory_util'] = m.MEMORY_UTIL;
    vals['iops'] = m.IOPS;
    vals['avg_srv_tim'] = m.AVG_SRV_TIME;

    var tags = {};
    for (var i in tagNames) {
         tags[tagNames[i].toLowerCase()] = m[tagNames[i]];
    }

    res.push({
        measurement: 'server_1d',
        fields: vals,
        tags: tags,
        timestamp: new Date(m.TIMESTAMP)
    });
}
msg.payload = res;
return msg;


## online data

## Stat 12c SYSMETRIC

msg.topic = 'stat';
msg.query = `
-- RAC gv$sysmetric v12.1
select
    to_char(end_time, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
    case when d.CON_ID=0 then d.DBID else d.CON_DBID end as DBID,
    d.NAME as DBNAME,
    m.CON_ID,
    i.INSTANCE_NAME,
    i.HOST_NAME,
    m.METRIC_NAME as METRIC_NAME,
    m.METRIC_UNIT,
    round(m.value,2) as AVG,
    case
      when METRIC_NAME = 'Database Time Per Sec' then 'response_time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'response_time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'response_time'
      when METRIC_NAME = 'SQL Service Response Time' then 'response_time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'cpu'
      when METRIC_NAME = 'CPU Usage Per Txn' then 'cpu'
      when METRIC_NAME = 'User Calls Per Sec' then 'cpu'
      when METRIC_NAME = 'Host CPU Utilization (%)' then 'cpu'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'redo'
      when METRIC_NAME = 'Session Count' then 'session'
      when METRIC_NAME = 'Logons Per Sec' then 'session'
      when METRIC_NAME = 'User Commits Per Sec' then 'transactions'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'transactions'
      when METRIC_NAME = 'DB Block Changes Per Sec' then 'io'
      when METRIC_NAME = 'DB Block Gets Per Sec' then 'io'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'io'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'io'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'io'
      when METRIC_NAME = 'Current Open Cursors Count' then 'cursors'
      when METRIC_NAME = 'Temp Space Used' then 'memory'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'memory'
      when METRIC_NAME = 'I/O Requests per Second' then 'io'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'io'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'parsing'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'pq'
    else 'other' end as METRIC_TYPE,
    case
      when METRIC_NAME = 'Database Time Per Sec' then 'Database_Time'
      when METRIC_NAME = 'Database CPU Time Ratio' then 'Database_CPU_Time'
      when METRIC_NAME = 'Database Wait Time Ratio' then 'Database_Wait_Time'
      when METRIC_NAME = 'SQL Service Response Time' then 'SQL_Service_Response_Time'
      when METRIC_NAME = 'CPU Usage Per Sec' then 'cpu_usage'
      when METRIC_NAME = 'CPU Usage Per Txn' then 'cpu_usage_txn'
      when METRIC_NAME = 'User Calls Per Sec' then 'user_calls'
      when METRIC_NAME = 'Host CPU Utilization (%)' then 'Host_CPU_Utilization'
      when METRIC_NAME = 'Redo Generated Per Sec' then 'Redo_Generated'
      when METRIC_NAME = 'Session Count' then 'Session_Count'
      when METRIC_NAME = 'Logons Per Sec' then 'Logons'
      when METRIC_NAME = 'User Commits Per Sec' then 'User_Commits'
      when METRIC_NAME = 'User Rollbacks Per Sec' then 'User_Rollbacks'
      when METRIC_NAME = 'DB Block Changes Per Sec' then 'db_block_changes'
      when METRIC_NAME = 'DB Block Gets Per Sec' then 'db_block_gets'
      when METRIC_NAME = 'Logical Reads Per Sec' then 'Logical_Reads'
      when METRIC_NAME = 'Total Table Scans Per Sec' then 'total_table_scans'
      when METRIC_NAME = 'Full Index Scans Per Sec' then 'full_index_scans'
      when METRIC_NAME = 'Current Open Cursors Count' then 'Current_Open_Cursors'
      when METRIC_NAME = 'Temp Space Used' then 'Temp_Space_Used'
      when METRIC_NAME = 'Disk Sort Per Sec' then 'Disk_Sort'
      when METRIC_NAME = 'I/O Requests per Second' then 'IO_Requests'
      when METRIC_NAME = 'I/O Megabytes per Second' then 'IO_Megabytes'
      when METRIC_NAME = 'Total Parse Count Per Sec' then 'Total_Parse'
      when METRIC_NAME = 'Hard Parse Count Per Sec' then 'Hard_Parse'
      when METRIC_NAME = 'Queries parallelized Per Sec' then 'Queries_parallelized'
    else 'other' end as METRIC
from
  GV$SYSMETRIC m
  join GV$INSTANCE i ON (m.inst_id = i.inst_id AND i.CON_ID = m.CON_ID)
  join GV$DATABASE d ON (i.inst_id = d.inst_id AND d.CON_ID = i.CON_ID)
where
     m.group_id = 2
 and m.METRIC_NAME in (
    'Database Time Per Sec',
    'Database CPU Time Ratio',
    'Database Wait Time Ratio',
    'SQL Service Response Time',
    'CPU Usage Per Sec',
    'CPU Usage Per Txn',
    'User Calls Per Sec',
    'Host CPU Utilization (%)',
    'Redo Generated Per Sec',
    'Session Count',
    'Logons Per Sec',
    'User Commits Per Sec',
    'User Rollbacks Per Sec',
    'DB Block Changes Per Sec',
    'DB Block Gets Per Sec',
    'Logical Reads Per Sec',
    'Total Table Scans Per Sec',
    'Full Index Scans Per Sec',
    'Current Open Cursors Count',
    'Temp Space Used',
    'Disk Sort Per Sec',
    'I/O Requests per Second',
    'I/O Megabytes per Second',
    'Total Parse Count Per Sec',
    'Hard Parse Count Per Sec',
    'Queries parallelized Per Sec'
    )
order by METRIC_NAME, METRIC_UNIT, INSTANCE_NAME, CON_ID
`;
return msg;

## memory stats

msg.topic = 'memory';
msg.query = `
select
   to_char(sysdate, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIMESTAMP,
   d.name as DBNAME,
   i.INSTANCE_NAME,
   HOST_NAME,
   lower(replace(p.name, ' ', '_')) as METRIC,
   VALUE,
   METRIC_UNIT,
   'memory' as METRIC_TYPE
 from (
        -- SGA info
        select
           INST_ID,
           name,
           round(bytes/power(1024,2)) AS VALUE,
           'MB' as METRIC_UNIT
          from gv$sgainfo
        UNION
        -- PGA info
        select INST_ID,
           name,
           case
             when unit = 'bytes' then round(value/1048576)
            else value
          end VALUE,
          decode (unit,'bytes','MB') METRIC_UNIT
         from    gv$pgastat
          where name in ('aggregate PGA target parameter','aggregate PGA auto target',
             'total PGA allocated','cache hit percentage','over allocation count')
     ) p
      join GV$INSTANCE i on (p.inst_id = i.inst_id)
      join GV$DATABASE d on (d.inst_id = i.inst_id)
order by INSTANCE_NAME, METRIC
`;
return msg;

## Wait Class

- unit: Active_Sessions
- union s CPU pro zobrazení jako ASH data

msg.topic = 'rtclass';
msg.query = `
select
    to_char(END_TIME, 'YYYY-MM-DD"T"HH24:MI:SS"+01:00"') as TIME,
    d.dbid,
    d.name as dbname,
    m.CON_ID,
    i.INSTANCE_NAME,
    HOST_NAME,
    RT_CLASS,
    'average_active_sessions' as METRIC_UNIT,
    AAS as AVG,
    'rt_class' as METRIC_TYPE
from (
select
  m.END_TIME,
  m.CON_ID,
  m.inst_id,
  replace(n.WAIT_CLASS,' ','_') as RT_CLASS,
  round(m.time_waited/m.INTSIZE_CSEC,3) AAS
 from
  gv$waitclassmetric m
  join v$system_wait_class n on
     (m.wait_class_id=n.wait_class_id)
 where n.wait_class != 'Idle'
union
select END_TIME, m.CON_ID, m.inst_id, 'CPU', round(value/100,3) AAS
 from gv$sysmetric m where metric_name='CPU Usage Per Sec' and group_id=2
) m, GV$INSTANCE i, V$DATABASE d
where m.inst_id = i.inst_id
order by RT_CLASS, INSTANCE_NAME, CON_ID
`;
return msg;



## Wait event metriky

- lepší sbírat online na úrovni direct DB

-- online sber dat
msg.topic = 'wait';
msg.query = `
-- RAC GV$EVENTMETRIC verze 12c
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
 GV$EVENTMETRIC m, V$EVENT_NAME e, GV$INSTANCE i, V$DATABASE d
where
 d.CON_ID = i.CON_ID
 AND m.inst_id = i.inst_id
 --m.INTSIZE_CSEC>5000 and m.BEGIN_TIME>(sysdate-1/24/60*3) and
 and m.EVENT_ID = e.EVENT_ID and
 e.NAME in (
    'log file parallel write',
    'log file sync',
    'db file scattered read',
    'db file sequential read',
    'resmgr:cpu quantum'
    )
)
group by METRIC,METRIC_UNIT,INSTANCE_NAME,CON_ID
order by METRIC,METRIC_UNIT,INSTANCE_NAME,CON_ID
`;
return msg;


- EM verze
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


## db size - historická data

-- db size historicky
SELECT
    to_char(ma.rollup_timestamp,'YYYY-MM-DD') AS "DATE",
    (ma.rollup_timestamp - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000 * 1000000  AS timestamp,
    d.entity_name dbname,
    d.host_name,
    p.PROPERTY_VALUE env_status,
    ma.average as ma_value,
    mu.average as mu_value
FROM
    sysman.MGMT$METRIC_DAILY ma
    JOIN sysman.MGMT$METRIC_DAILY mu on (
           ma.target_guid = mu.target_guid
       AND ma.rollup_timestamp = mu.rollup_timestamp)
    JOIN sysman.EM_MANAGEABLE_ENTITIES d ON (ma.target_guid = d.entity_guid)
    join sysman.MGMT_TARGET_PROPERTIES p on (p.target_guid = d.entity_guid)
WHERE
  d.category_prop_3 = 'DB'
  AND   p.property_name = 'orcl_gtp_lifecycle_status'
  AND   ma.metric_name = 'DATABASE_SIZE'
  AND   ma.metric_column in ('ALLOCATED_GB')
  AND   mu.metric_column in ('USED_GB')
  AND   p.property_value is not NULL
  AND   d.entity_name LIKE 'A%'
--ORDER BY timestamp, dbname, env_status, metric_name
ORDER BY dbname
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY
)
;

