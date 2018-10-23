--
-- SQL profile
--

-- zjisteni stavajiciho SQL profile a SQL hintu
select inst_id, sql_id, plan_hash_value,
       optimizer_cost, sql_profile, sql_patch
  from gv$sql
 where sql_id sql_id in ('gygdvbjdj9gvq', '939d23gvdvs58')
;

--
-- coe_load_sql_profile.sql
select * from dba_sql_profiles
 -- where name = 'SYS_SQLPROF_02669aacf8d20002'
 order by created DESC;

-- COE script
@/dba/sql/coe_xfr_sql_profile

-- a pak pustit vygenerovaný SQL skript
@coe_xfr_sql_profile_5htf3c7z5fka1_1333230131.sql


-- hint list
SELECT extractValue(value(h),'.') AS hint
FROM sys.sqlobj$data od, sys.sqlobj$ so,
table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
WHERE so.name = 'SYS_SQLPROF_036695a06bab0001'
AND so.signature = od.signature
AND so.category = od.category
AND so.obj_type = od.obj_type
AND so.plan_id = od.plan_id;

select
    rat.attr1
from
    sys.wri$_adv_tasks        tsk,
    sys.wri$_adv_rationale    rat
where
    tsk.name = 'SQL_TUNING_2r4y22hyn58hw'
and	rat.task_id   = tsk.id
;


-- drop SQL profile
define sql_profile = SYS_SQLPROF_02669aacf8d20002

BEGIN
  DBMS_SQLTUNE.DROP_SQL_PROFILE (
    name => '&sql_profile'
);
END;
/

-- import SQL profile from STAGE
imp system full=y file=VASEK_PROFILE_STGTAB.dmp

BEGIN
DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF (
  REPLACE => TRUE,
  staging_table_name => 'VASEK_PROFILE_STGTAB',
  staging_schema_owner => 'SYSTEM');
END;
/

select * from DBA_SQLTUNE_STATISTICS

select * from DBA_SQLTUNE_PLANS

SELECT   s.begin_interval_time, SQL.sql_id, SQL.sql_profile,
             TRUNC (SQL.elapsed_time_delta / SQL.executions_delta / 1000000
                   ) "elapsed time"
        FROM SYS.wrh$_sqlstat SQL, dba_hist_snapshot s
       WHERE SQL.sql_profile is not null AND SQL.snap_id = s.snap_id
   ORDER BY 1 ASC

   --> SYS_SQLPROF_0145b25b145b25b8

select * from v$sql
where sql_id = '2r4y22hyn58hw'


select * from DBA_ADVISOR_TASKS
where advisor_name = 'SQL Tuning Advisor'

select * from DBA_SQLSET_BINDS




select * from TABLE (DBMS_XPLAN.display_awr('2r4y22hyn58hw', null, null, 'ALL'))

SELECT DBMS_SQLTUNE.report_tuning_task('SQL_TUNING_2r4y22hyn58hw', 'TEXT','TYPICAL','ALL',NULL,NULL)   FROM dual;


