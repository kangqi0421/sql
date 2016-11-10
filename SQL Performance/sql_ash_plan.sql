DEFINE sqlid=bz6u8drcvdxhp
DEFINE child=%

WITH  sample_times AS (
    select * from dual
), 
sq AS (
SELECT
    count(*) samples
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
FROM
     v$active_session_history ash
--    dba_hist_active_sess_history ash
WHERE
    1=1
--AND sample_time > sysdate - 4/24    
AND ash.sql_id LIKE '&sqlid'
AND ash.sql_child_number LIKE '&child'
GROUP BY
    ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
)
SELECT
    plan.sql_id            asqlmon_sql_id
  , plan.child_number      asqlmon_sql_child
--  , plan.plan_hash_value asqlmon_plan_hash_value
  , sq.samples seconds
 , ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100, 1) pct_child
 --, '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 10), '#'), ' '), 10,' ')||'|' pct_child_vis
 , 'SQLDEV:GAUGE:0:100:0:100:'||ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100,1) pct_child_vis
  --, sq.sample_time         asqlmon_sample_time
  , plan.id 
  , LPAD(' ', depth) || plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_name ||']', null) asqlmon_operation
  , sq.session_state
  , sq.event
  , plan.object_alias || CASE WHEN plan.qblock_name IS NOT NULL THEN ' ['|| plan.qblock_name || ']' END obj_alias_qbc_name
  , CASE WHEN plan.access_predicates IS NOT NULL THEN '[A:] '|| plan.access_predicates END || CASE WHEN plan.filter_predicates IS NOT NULL THEN ' [F:]' || plan.filter_predicates END asqlmon_predicates
  , plan.projection
FROM
    v$sql_plan plan
  , sq
WHERE
    1=1
AND sq.sql_id(+) = plan.sql_id
AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
AND plan.sql_id LIKE '&&sqlid'
AND plan.child_number LIKE '&&child'
--ORDER BY  plan.child_number, plan.plan_hash_value, plan.id
ORDER BY seconds desc nulls last
/