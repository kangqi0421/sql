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

-- Grafana EPOCH timestamp
(m.rollup_timestamp - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000 * 1000000  AS timestamp,


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

## metriky bez key_value
- DATABASE_SIZE
- nová verze SQL
SELECT
     TO_CHAR(val.collection_time,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS timestamp,
     c.entity_name AS dbname,
     c.entity_type,
     p.PROPERTY_VALUE env_status,
     k.key_part_1 AS tbs_name,
     t.host_name,
     lower(c.metric_column_name) metric_name,
     c.metric_column_label metric_label,
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
     join sysman.MGMT_TARGET_PROPERTIES p on p.target_guid = c.entity_guid
WHERE
     c.METRIC_GROUP_NAME = 'DATABASE_SIZE'
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
ORDER BY timestamp, dbname, env_status, metric_name;

--

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
    AND metric_column in ('usable_file_mb',  -- Disk Group Usable (MB)
                          'total_mb')        -- Size (MB)
;

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
  AND key_value in ('log file sync', 'log file parallel write', 'direct path read temp',
                    'control file sequential read', 'direct path read',
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