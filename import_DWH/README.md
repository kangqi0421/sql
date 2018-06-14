# Migrace DWH z Vidne (AIX) do Prahy (Linux)

## Dokumenty
[DWH PoC](https://docs.google.com/spreadsheets/d/1wimTCfr7ZeAVcEzkCU2xaf_JrA38PqbIzm94Yu2h6Qs)

## VM servery pro PoC

tpdwhdb01
tpdwhdb02

## DWHDDP

provedené optimalizace a změny na cílové db na Linuxu:

- db_block_size - změnit na 16k
- přidat komponentu Oracle Text
- extend VARCHAR2/CHAR - povolit pro migraci do UTF8
- vypnout audit - nutnost při importu
```
-- NOAUDIT all
BEGIN
  FOR rec IN
    (SELECT POLICY_NAME, decode(USER_NAME,'ALL USERS','',' BY '||USER_NAME) as username
    FROM AUDIT_UNIFIED_ENABLED_POLICIES)
  LOOP
    EXECUTE immediate 'noaudit policy '||rec.policy_name||' '||rec.username;
end LOOP;
END;
/
```
- import profile a rolí = false - pouze pro opakovaný běh importu
- TEMP BIGILE (pouze pro import) + normalni TEMP
- UNDO - zmigrovat na bigfile
- NOARCHIVELOG
- disable force logging - pro omezení redo během importu
- redo size - switch online redo na na 8x 1024
```
sql @/dba/sql/CREATE_DB/switch_redo.sql 1024
sql @/dba/sql/CREATE_DB/add_redo.sql 1024 8
```

## import roles

```
impdp system/s NETWORK_LINK=EXPORT_IMPDP full=y nologfile=y INCLUDE=ROLE,PROC_SYSTEM_GRANT,SYSTEM_GRANT,ROLE_GRANT,DEFAULT_ROLE,PASSWORD_VERIFY_FUNCTION,PROFILE
```

## import prereq users role "OLAP_USER"

```
create role OLAP_USER;
```

## SYSEL - DBA účet pro Hamouze

```
at now <<< "/dba/local/bin/import_dblink.sh DWHSRC2 DWHPOC SYSEL &>import.log"
```

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

## indexes

vytváření indexů je současát předchozích kroků migrace, import přes impdp. Používá se pouze v případě, že něco selhalo.

- zvednout PGA_AGGREGATE_TARGET co to jde ...
```
alter system set pga_aggregate_target = 40G;
```
- impdp include=REF_CONSTRAINT,INDEX


```
schemas=DWH_OWNER,ODI_ADS_USER,TEMP_OWNER,CESS_FPV_OWNER,RUSA_OWNER,RATING_OWNER,RUSB_OWNER,ADS_RETAIL_OWNER,DAMI_OWNER

OPTIONS=" CONTENT=ALL NETWORK_LINK=EXPORT_IMPDP NOLOGFILE=y METRICS=YES"
for schema in ${schemas//,/ }
do
  at now <<< "impdp system/s schemas=${schema} INCLUDE=REF_CONSTRAINT,INDEX $OPTIONS &>index_${schema}.log"
done
```

## import identity column - nelze importovat přes framework

ORA-14300: partitioning key maps to a partition outside

```
cat > tables.par <<EOC
TABLES=ETL_OWNER.ACCOUNT_OPENING_BALANCES
TABLES=ETL_OWNER.ETL_MIGRATION_OBJECTS
TABLES=ETL_OWNER.ETL_MIGRATION_OBJECT_LOGS
TABLES=ETL_OWNER.ETL_OBJECT_CONSOLIDATED_NAMES
TABLES=RUSB_OWNER.CEN36450_SCX_AUM_EPR
TABLES=RUSB_OWNER.DG_F_VIEWTRACKER
TABLES=RUSB_OWNER.DQ_E_EG_REPO
TABLES=RUSB_OWNER.JBO_DOCP_BASE
TABLES=RUSB_OWNER.MB_R_PARTY_DQI
EOC

OPTIONS=" CONTENT=ALL PARALLEL=32 NETWORK_LINK=EXPORT_IMPDP nologfile=y "
at now <<< "impdp system/s  exclude=STATISTICS TABLE_EXISTS_ACTION=TRUNCATE parfile=tables.par $OPTIONS &> impdp_${ORACLE_SID}_reimp_identity_$(date +%Y%m%d_%H%M%S).log"
```


## import prazdnych schemat

```
schemas="OWF_MGR,A4076778,A4077279,ADS_CORP_ETL_OWNER,ADS_CORP_OWNER,ADS_RETAIL_ETL_OWNER,ALMDM2_OWNER,BLEWIS,BV036416,CDOUGLAS,CESS_FPV_USER,CESS_LISIFE_USER,CESS_RUSA_DPH,COGNOSDMA1,COGNOSDMA2,COGNOSDMADEV,COGNOSDWH1,COGNOSDWH2,COGNOSDWHCHECK,COGNOSDWHOUT,COGNOSSPDWH,COGNOSSPDWHDEV,COGNOS_CORP_READ,COGNOS_EAM_READ,COGNOS_RUSA_ADK,COGNOS_RUSA_BOF,COGNOS_RUSA_BRA,COGNOS_RUSA_CA,COGNOS_RUSA_CAM,COGNOS_RUSA_CCB,COGNOS_RUSA_CEI,COGNOS_RUSA_COMP,COGNOS_RUSA_CPS,COGNOS_RUSA_DMM,COGNOS_RUSA_EI,COGNOS_RUSA_EWS,COGNOS_RUSA_HRM,COGNOS_RUSA_HYPO,COGNOS_RUSA_IREP,COGNOS_RUSA_LAP,COGNOS_RUSA_LEA,COGNOS_RUSA_OPT,COGNOS_RUSA_RSM,COGNOS_RUSA_SCX,COGNOS_RUSA_TA,COGNOS_RUSA_TECH,COGNOS_RUSA_TPS,COGNOS_RUSA_UNO,COGNOS_RUSA_VP,COGNOS_RUSA_ZPS,COGNOS_RUSB_D3REP,COGNOS_RUSB_TECH,COGNOS_VDS_RETAIL,COGNO_SVC,CPT_USER,CRIBIS_OWNER,CRS_USER,CSOPS_IMPORT,DAMI_ETL_OWNER,DBSPI,DC_OWNER,DICT_USER,DLK_USER,DQ_OWNER,DQ_USER,DWH_CTRL_USER,DWH_DAMI_AUTOLOAD,DWH_RRDM_USER,DWH_SODS_USER,ETL_VIEW,FATCA_USER,FR_OWNER,GROH,KL035794,KWALKER,ODI_CONS_USER,ODI_DWH_USER,ODI_ETL,ODI_EXE,ODI_LIC_USER,OEM_DWHPO_PRODODS,OLAPSVR,OWBSYS,OWBSYS_AUDIT,OWB_RUNTIME,OWF_USR,PPM_USER,PRICE_USER,PROCAL_OWNER,PROCAL_USER,RATING_USER,RA_USER,REDIM_USER,REP_MGR,REP_OWNER,RESTORE_PRE_LR2016,RINT_OWNER,RR_OWNER,RR_USER,RTODS_USER,SOL60237,SPDWHDEV,SPIERSON,SYSADMIN,SYSEL,TABLE_SVC,TC,TES00001,TES12345,TEST97136,TUXCRM,VA_USER,VDS_RETAIL_ETL_OWNER,VDS_RETAIL_OWNER,WFADMIN"

at now <<< "/dba/local/bin/import_dblink.sh DWHSRC2 DWHPOC $schemas &>import_others.log"
```

## SYSTEM tables

definice SYSTEM tabulek:
```
select 'TABLES='||
       owner ||'.'|| object_name
  from dba_objects@export_impdp
  where owner = 'SYSTEM'
    and oracle_maintained = 'N'
    and object_type like 'TABLE'
    and object_name not like 'DUM$%'
order by object_name;
```

import SYSTEM tabulek
```
cat > system_tables.par <<EOC
TABLES=SYSTEM.ADMIN_DB_USERS_LOG
TABLES=SYSTEM.DBA_LOG
TABLES=SYSTEM.DB_LOGON_ACCESS
TABLES=SYSTEM.DB_LOGON_AUDIT_CONFIG
TABLES=SYSTEM.DB_LOGON_AUDIT_CONFIG_BCK
TABLES=SYSTEM.DB_LOGON_OS_USER_PERMANENT
TABLES=SYSTEM.DB_TRACED_USERS
EOC

impdp system/s parfile=system_tables.par content=ALL NETWORK_LINK=EXPORT_IMPDP nologfile=y
```

SYSTEM packages and triggers
```
sql @/dba/local/sql/SYSTEM_OBJECTS.sql
```


## public granty

```
sqlplus system/s @dwh_post_task.sql
```

znovu přegrantovat PUBLIC a SYS granty
```
sqlplus / as sysdba @public.sql
```

## full import GRANT

at now <<< "impdp system/s NETWORK_LINK=EXPORT_IMPDP full=y nologfile=y INCLUDE=PROC_SYSTEM_GRANT,SYSTEM_GRANT,ROLE_GRANT,DEFAULT_ROLE,OBJECT_GRANT &>grants.log"

## import post akce

reset init params
```
@reset_init_params.sql
```

restart db
```
srvctl stop db -d ${ORACLE_SID%%[1-9]} && srvctl start db -d ${ORACLE_SID%%[1-9]} 
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
