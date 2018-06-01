# Migrace DWH z Vidne (AIX) do Prahy (Linux)

## Dokumenty
[DWH PoC] (https://docs.google.com/spreadsheets/d/1wimTCfr7ZeAVcEzkCU2xaf_JrA38PqbIzm94Yu2h6Qs)

## Migrace s pouzitim pouze datapump
```shell
ssh oracle@tpdwhdb01

export ORACLE_SID=DWHPOC
. oraenv </dev/null

schemas=...,...
mk
at now <<< "/dba/local/bin/import_dblink.sh DWHSRC2 DWHPOC $schemas &>import.log"
```

## Migrace s pouzitim Jirkova super import framework
pozor: nelze pustit paralelně skript vícekrát, používá jednu load tabulku
```shell
ssh oracle@tpdwhdb01

export ORACLE_SID=DWHPOC
. oraenv </dev/null

schemas=...
mk
at now <<< "/dba/local/bin/import_dwh_metadata.sh DWHSRC2 DWHPOC $schemas &>import.log"
```

## Kontrola objektu
```sql
select OWNER, OBJECT_TYPE, count(*)
from dba_objects@export_impdp
where OWNER in (
    select username
      from IMPORT_SCHEMA
     -- where size_gb < 100
     )
 and OBJECT_NAME not like 'SYS%'
group by OWNER, OBJECT_TYPE
minus
select OWNER, OBJECT_TYPE, count(*)
from dba_objects
where OWNER in (
    select username
      from IMPORT_SCHEMA
     --where size_gb < 100 
     )
 and OBJECT_NAME not like 'SYS%'
group by OWNER, OBJECT_TYPE
order by 1,2;
```

## Kontrola dbms_parallel_execute
```sql
-- status
select * from DBA_PARALLEL_EXECUTE_TASKS
  order by job_prefix desc;

SELECT 
    *
  FROM dba_parallel_execute_chunks
 WHERE 1 = 1
   and task_name = 'IMPORT_TASK$_1595662'
--    and start_ts > sysdate - interval '1' day
--   and status = 'PROCESSED_WITH_ERROR'
--   and error_code in (-14300, -14401)
   --and error_code = -1400
--   and status like 'PROC%'
--group by error_code   
  order by end_ts DESC
```
