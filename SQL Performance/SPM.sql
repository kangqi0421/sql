--
-- 	FAQ: SQL Plan Management (SPM) Frequently Asked Questions (Doc ID 1524658.1)
--



Adaptive SQL Plan Management (SPM) - automaticky evolvuje plány


SELECT * FROM DBA_SQL_PLAN_BASELINES;

SELECT SQL_HANDLE, PLAN_NAME, ENABLED, ACCEPTED, FIXED
FROM DBA_SQL_PLAN_BASELINES
  where origin = 'AUTO-CAPTURE'
--    and sql_handle = 'SQL_ced5c732f0c8c027'
      AND fixed = 'YES'
order by elapsed_time desc;


-- konfigurace
SELECT parameter_name, parameter_value
FROM   dba_sql_management_config;


DEFINE sqlid=3crh81fz1h5fd

--
SELECT sql_handle, plan_name
FROM dba_sql_plan_baselines
WHERE signature IN (
  SELECT exact_matching_signature FROM v$sql WHERE sql_id='&sqlid'
)
/


-- step by step SPM

-- automatický sběr
OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES = true

-- manual load the sql to base line from cursor cache
DECLARE
my_plans pls_integer;
BEGIN
my_plans := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => '&sqlid');
END;
/

-- manual load from AWR -> sql tunning set
exec  dbms_sqltune.create_sqlset(sqlset_name => 'sql_tuning_set_.&sqlid',description => '&sqlid');

declare
ref_cur DBMS_SQLTUNE.SQLSET_CURSOR;
begin
open ref_cur for
select VALUE(p) from table(
DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY( &begin_snap_id, &end_snap_id, basic_filter=>'sql_id=''&sqlid''',attribute_list =>'ALL')) p;
DBMS_SQLTUNE.LOAD_SQLSET('sql_tuning_set_.&sqlid', ref_cur);
END;
/
select * from table(dbms_xplan.display_sqlset('sql_tuning_set_.&sqlid','&sql_id'));

DECLARE
my_plans pls_integer;
BEGIN
my_plans := dbms_spm.load_plans_from_sqlset(sqlset_name => 'sql_tuning_set_.&sqlid');
END;
/

-- let’s fix the new plan SYS_SQL_PLAN_9456f9be3e1ca9ac
DECLARE
my_plans pls_integer;
BEGIN
my_plans := DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
  sql_handle  => NULL,
  plan_name   => 'SQL_PLAN_c8tkm626rx1hdda39dcb5',
  attribute_name => 'fixed',
  attribute_value => 'YES'
);
END;
/

-- display
SELECT *
  FROM TABLE (
          DBMS_XPLAN.display_sql_plan_baseline (
		          sql_handle   => '&sql_handle',
                  format       => 'basic')
		      );
												--
-- drop and clean sql baseline
DECLARE
my_plans pls_integer;
BEGIN
my_plans := DBMS_SPM.DROP_SQL_PLAN_BASELINE (sql_handle => '&sql_handle');
END;
/

select sql_handle,sql_text from DBA_SQL_PLAN_BASELINES;

SELECT sql_handle, plan_name
FROM dba_sql_plan_baselines
WHERE signature IN (
  SELECT exact_matching_signature FROM v$sql WHERE sql_id='&SQL_ID')
);