--
-- inmemory option
--
https://blogs.oracle.com/In-Memory/entry/getting_started_with_oracle_database1

In Memory přináší největší urychlení operací v následujících případech
- Dotazy, které zpracovávají vysoké počty řádků a používají následující filtry   =, <, >, a IN
- Dotazy, které zpracovávají malé množství sloupců z tabulky nebo materializovaného view s velkým počten sloupců
- Dotazy, které spojují malou a velkou tabulku.
- Dotazy, které provádějí agregace

--
-- STATUS - out of memery
--

-- Inmemory advisor
stáhnout z MOS a spustit
- Oracle Database In-Memory Advisor (Doc ID 1965343.1)

-- running advisor
@imadvisor_recommendations


select * from DBA_IMA_TASK_INFORMATION;

-- LOAD TABLES

-- prvních 50 z každého tasku
-- uniq, partition modify
select
  'ALTER TABLE '||
  table_owner||'.'||table_name||
  partition_name||
  ' INMEMORY;'
from
(
select
  table_owner, table_name,
  NVL2( partition_name, ' MODIFY PARTITION '||partition_name, '' ) partition_name
--  count(*)
from DBA_IMA_RECOMMENDATIONS
  where 1=1
  --and task_name = 'im_advisor_task_20161213123519'
  and status = 'accepted'
  --and table_name = 'PARTY_PRODUCT_INST'
  -- pouze TOP 50 tabulek
  and rank < 50
  group by table_owner, table_name, partition_name
--  order by rank
)
;

-- TABLESPACE level

-- testováno na RTOP ve Vídni
INMEMORY_SIZE = integer [K | M | G]

alter system set SGA_TARGET = 400G scope=spfile;
alter system set INMEMORY_SIZE = 300G scope=spfile;

-- když tak zvednout i
PGA_AGGREGATE_TARGET = min (INMEMORY_SIZE X 0.5)
alter system set PGA_AGGREGATE_TARGET = 150G;


-- implementace
ALTER TABLE AUX_OWNER.MAP_CURRENCY NO INMEMORY;

select owner, TABLE_NAME, inmemory, inmemory_priority
  from dba_tables
  where inmemory = 'ENABLED'
  and table_name = 'MAP_CURRENCY'
;

-- NO INMEMORY
select 'ALTER TABLE ' || owner||'.'||TABLE_NAME || ' NO INMEMORY;'
  --, inmemory, inmemory_priority
  from dba_tables
  where inmemory = 'ENABLED'
  --and table_name = 'MAP_CURRENCY'
;

-- sga status
select name, round(value/1024/1024/1024) "GB" from v$sga;

col POOL for a10
col POPULATE_STATUS for a12
select
  POOL, ROUND(ALLOC_BYTES/1024/1024/1024,2) as "ALLOC_BYTES_GB",
  ROUND(USED_BYTES/1024/1024/1024,2) as "USED_BYTES_GB",
  populate_status
 from V$INMEMORY_AREA;

-- kolik dat se načetlo
SELECT mem inmem_size,
       tot disk_size,
       bytes_not_pop,
       round((tot/mem),1) compression_ratio,
       round(100 *((tot-bytes_not_pop)/tot)) populate_percent
FROM
  (SELECT
    ROUND(SUM(INMEMORY_SIZE)/1024/1024/1024) mem,
    ROUND(SUM(bytes)              /1024/1024/1024) tot ,
    ROUND(SUM(bytes_not_populated)/1024/1024/1024) bytes_not_pop
   FROM v$im_segments
   )
/


--
--
SELECT segment_name,
       inmemory_size, inmemory_compression,
       round(bytes/inmemory_size) comp_ratio,
       populate_status,
       bytes_not_populated
FROM v$im_segments;


-- testcase
select sum(), count(*) from t;

zobrazit na explain plain