--
-- HP Monitor
-- view pro kapacitní plánování

-- provést join metriky s MGMT$DB_DBNINSTANCEINFO d

#1) udelat jeden pohled pro tablespace, kde je relace database : tablspace = 1 : N
pohled1: timestamp, db_name, tablespace_name, tablespace_metric1, ..., tablespace_metricN

Format timestamp potrebujeme "yyyy-mm-dd hh:mm:ss.ttt" (string)
Format metrik muze byt float


SELECT
   to_char(m.collection_timestamp,'yyyy-mm-dd hh:mm:ss') "timestamp",
   d.DATABASE_NAME db_name,
   m.target_guid,
   m.metric_column, m.column_label,
   m.key_value, m.value
FROM
  MGMT$METRIC_DETAILS m
  JOIN mgmt$db_dbninstanceinfo d ON (m.target_guid = d.target_guid)
WHERE
   m.target_name like 'CPTDA'
  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column in ('spaceUsed', 'spaceAllocated')
--   AND m.column_label = 'Tablespace Used Space (MB)'
ORDER by 1, 2
;



1), 2) tablespace - ANO
 - Zaplnění Oracle Filesystemu
  - Maximální velikost tablespace

OEM metriky:
- Tablespace Allocated Space (MB)
- Tablespace Used Space (MB)


  AND m.metric_name = 'tbspAllocation'
  AND m.metric_column = 'spaceAllocated'
  AND m.metric_label like 'Tablespace Allocation'

2a) - Zaplnění tablespace = velikost databáze - ANO

OEM metriky:
m.metric_name ='DATABASE_SIZE' AND m.metric_column ='ALLOCATED_GB'

2b) ASM metriky - ANO

velikost ASM diskgroupy a zaplnění ASM diskgroupy

OEM metriky:
ASM Disk Group Usage
- Disk Group Usable (MB)
- Size (MB)


3) Počet otevřených sessions v DB - ANO

OEM metriky:
 m.metric_column like 'logons'


4) čtení - IO latence single bloku [ms] - NE

Latence IO bloku je lepší sledovat na úrovni OS nebo úrovni SAN pole

5) zápis - log file sync - ANO

OEM metriky:
  AND m.metric_name = 'topWaitEvents'
  AND m.metric_column = 'averageWaitTime'
  AND column_label like 'Average Wait Time (millisecond)'
  AND key_value     = 'log file sync'

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