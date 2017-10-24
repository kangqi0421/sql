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


1), 2) tablespace - ANO
 - Zaplnění Oracle Filesystemu
  - Maximální velikost tablespace


#1) udelat jeden pohled pro tablespace, kde je relace database : tablspace = 1 : N
pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

Format timestamp potrebujeme "yyyy-mm-dd hh:mm:ss.ttt" (string)
Format metrik muze byt float

#1) tablespace, kde je relace database : tablspace = 1 : N

pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

-- tablespaces metriky
SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh24:mi:ss') "timestamp",
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

#2) dalsi pohled pro zbyvajici database metriky,

-- metriky bez key_value
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

#3) ASM metriky

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

#4) Wait event metriky

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