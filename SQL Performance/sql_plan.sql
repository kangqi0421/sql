--
-- SQL plan hash value, konrektni COST danych exec planu
--

-- reset ansiconsole
SET SQLFORMAT

DEFINE SQLID = 30k5vy2ycxzhp

DEFINE PLAN_HASH=%
DEFINE PLAN_HASH=653645620

-- hled�n� jednoho sql id za posledn� X hodin z ASH
SELECT  SQL_ID, COUNT(*) cnt
    FROM
--      dba_hist_active_sess_history ash
       GV$ACTIVE_SESSION_HISTORY ASH
  WHERE 1=1
    AND SAMPLE_TIME > sysdate - interval '1' hour
--    AND SAMPLE_TIME BETWEEN TIMESTAMP'2016-11-10 01:00:00'
--                        AND TIMESTAMP'2016-11-10 03:00:00'
  group by SQL_ID
  order by 2 desc;

select *
  from GV$ACTIVE_SESSION_HISTORY where sql_id = '&SQLID'
order by sample_time desc;


@sqlid &SQLID %

-- pocty sql id dle RAC instance
select inst_id, count(*)
  from gv$sql where sql_id = '&SQLID'
  group by inst_id
  order by inst_id;

-- adaptive plan ?
select inst_id, sql_id, child_number, plan_hash_value,
       optimizer_cost, sql_profile, sql_patch, FIRST_LOAD_TIME, users_executing
  from gv$sql
 where sql_id = '&SQLID'
  order by sql_id, first_load_time desc;

-- v$sql
set pages 999
@xi &SQLID &CHILD

-- dbms_xplan.display_awr
@xiawr &SQLID &PLAN_HASH

select * from table(dbms_xplan.display_awr('&SQLID',NULL,null, '+ALLSTATS'));
select * from table(dbms_xplan.display_awr('&SQLID','&PLAN_HASH',null, '+ALLSTATS'));

-- text based output
select plan_table_output from table (dbms_xplan.display_awr('&sqlid', '&PLAN_HASH'));

-- změna exec plánu
SELECT
--*
  timestamp, plan_hash_value, cost
--  id, operation, options, object_type, object_owner, object_name
--       sql_id, plan_hash_value, TIMESTAMP, COST
  FROM SYS.DBA_HIST_SQL_PLAN
 WHERE sql_id = '&sqlid'
    AND id = 0
--    and plan_hash_value in ('3223995408','384336403')
--  and object_name in ('CSAS_REL_RECORD_FILE_S', 'CS_IDX_CSAS_REL_RC_F_ID', 'D_1F02939680001D07')
order by timestamp desc, plan_hash_value, id
;

-- Analýza nesdílených kurzorů
@nonshared &SQLID %

SELECT * FROM TABLE(version_rpt('&SQLID'));


-- optimizer_adaptive_features = TRUE/FALSE
select
    ora_database_name,
    sql_id,
    plan_hash_value,
    cpu_time,
    elapsed_time,
    round(elapsed_time/1000/NULLIF(executions,0),0) AVG_ETIME_MS,
    round(cpu_time/1000/NULLIF(executions,0),0) AVG_CPUTIME_MS,
    executions,
    fetches,
    parse_calls,
    disk_reads,
    buffer_gets,
    rows_processed,
    sql_text
-- kontrola na bind peeking
--  Is_Bind_Aware, Is_Bind_Sensitive
  ,is_resolved_adaptive_plan
  from gv$sqlstats
 where sql_id='&SQLID'
order by sql_id ;

-- SQL duration z ASH
--alter session set nls_date_format = 'dd.mm.yyyy hh24:mi:ss';
SELECT   sql_id, sql_exec_start,
    sql_plan_hash_value,
    MAX(sample_time) end_sql,
    MAX(sample_time)-sql_exec_start AS duration
  FROM
--      DBA_HIST_ACTIVE_SESS_HISTORY
        GV$ACTIVE_SESSION_HISTORY
  WHERE 1   =1
      AND SAMPLE_TIME > sysdate - interval '4' hour
--    AND SAMPLE_TIME BETWEEN TIMESTAMP'2015-09-29 15:30:00'
--                        AND TIMESTAMP'2015-09-29 15:33:00'
  and SQL_ID like '&sqlid'
  and sql_exec_start is not null
  GROUP BY sql_id, sql_exec_start, SQL_PLAN_HASH_VALUE
  ORDER BY sql_id, sql_exec_start DESC;

-- SQL stats, group by plan_hash_value
-- time in microsec, divided to sec
SELECT
      sql_id,
--      min(plan_hash_value),
--      min(begin_interval_time),
      ROUND(SUM(elapsed_time_delta/1000000)/NULLIF(SUM(executions_delta),0),0)  "elapsed [s]/exec",
      ROUND(SUM(cpu_time_delta /1000000)/NULLIF(SUM(executions_delta),0),0)     "cpu_time [s]/exec",
	    ROUND(SUM(ROWS_PROCESSED_DELTA)/NULLIF(SUM(executions_delta),0))          "rows_processed/exec",
      SUM(executions_delta)                                                     "executions"
  FROM SYS.DBA_HIST_SQLSTAT NATURAL JOIN DBA_HIST_SNAPSHOT
 WHERE sql_id = '&sqlid'
   AND end_interval_time > sysdate - interval '7' day
  GROUP by sql_id
  --having SUM(executions_delta) > 0
order by 3 desc
;

--// SQL Plan line id a operation
SELECT   a.SQL_ID, a.sql_plan_hash_value,
    --a.SQL_EXEC_START,
    a.sql_plan_line_id,
    SQL_PLAN_OPERATION,
    p.object_name,
    COUNT(*),
    --PARTITION BY a.sql_id, a.sql_plan_hash_value
    ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY a.sql_id) * 100, 1) "pct"
  FROM
--   GV$ACTIVE_SESSION_HISTORY
     dba_hist_active_sess_history a inner join DBA_HIST_SQL_PLAN p
          on (a.sql_id = p.SQL_ID
              and a.sql_plan_hash_value(+) = p.plan_hash_value
              and a.sql_plan_line_id(+) = p.id)
        WHERE 1 = 1
        AND a.SQL_ID IN ('&sqlid')
        --and sql_plan_hash_value = '&PLAN_HASH'
--        AND a.sample_time > sysdate - interval '4' hour
--        AND SAMPLE_TIME BETWEEN TIMESTAMP'2015-02-15 23:30:00'
--                            AND TIMESTAMP'2015-02-16 09:00:00'
          --        AND SQL_PLAN_OPERATION = 'HASH JOIN'
        and a.sql_plan_hash_value = 384336403
        AND a.SQL_EXEC_START IS NOT NULL
  GROUP BY a.SQL_ID, a.sql_plan_hash_value, a.sql_plan_line_id, p.object_name,SQL_PLAN_OPERATION
    --a.SQL_EXEC_START,
  ORDER BY COUNT(*) DESC
  ;

-- porovn�n� z DBA_HIST_SQLSTAT pro shodn� SQL s liter�ly (dle force_matching_signature)
select sql_id, force_matching_signature  ,
ROUND(SUM(elapsed_time_delta/1000000)/NULLIF(SUM(executions_delta),0),0)  "elapsed time",
      ROUND(SUM(cpu_time_delta /1000000)/NULLIF(SUM(executions_delta),0),0)     "cpu time",
	    ROUND(SUM(ROWS_PROCESSED_DELTA)/NULLIF(SUM(executions_delta),0))          "rows processed",
      SUM(executions_delta)                                                     "executions"
from SYS.DBA_HIST_SQLSTAT
  where 1=1
    AND sql_id='&SQLID'
--    AND force_matching_signature = '13869317806829603650'
group by sql_id, force_matching_signature
order by 2, 3;

-- vyber tables z exec planu --
select
--    OWNER, TABLE_NAME, NUM_ROWS, LAST_ANALYZED
    OWNER, TABLE_NAME, NUM_ROWS, blocks, partitioned, LAST_ANALYZED, DEGREE
  from DBA_TABLES
where (owner, table_name) in (
SELECT  distinct object_owner,
    object_name
  FROM GV$SQL_PLAN
--    FROM DBA_HIST_SQL_PLAN
  WHERE SQL_ID        = '&sqlid'
--    WHERE SQL_ID in ('4k1xxjq1aymdt', '90rd3rb489wp6', '0mt9bj1u0uh4h', 'f58w05s13mspm')
  AND object_type     = 'TABLE'
  )
ORDER BY LAST_ANALYZED;

-- histogramy
-- ov��en� na histogramy, zda nem�n� pl�ny
select table_name,
       column_name,
       num_distinct,
       density,
       num_buckets,
       histogram
  from dba_tab_columns
where histogram <> 'NONE'
  AND (owner, table_name) in (
SELECT  distinct object_owner,
    object_name
  FROM GV$SQL_PLAN
  WHERE SQL_ID        = '&sqlid'  --9a5pr6jkppff6 &sqlid
  AND object_type     = 'TABLE'
  )
ORDER by 1,2;

-- nastaveni histogramu
select sname, sval1, spare4 from sys.optstat_hist_control$ order by sname;


-- SQL report --
@?/rdbms/admin/awrsqrpt

-- SPM
SELECT sql_handle, plan_name, s.plan_hash_value
FROM dba_sql_plan_baselines b join v$sql s
    on (s.exact_matching_signature = b.signature)
WHERE  s.sql_id='&SQLID'
;

-- FLUSH
SELECT 'exec dbms_shared_pool.purge ('''|| address||','|| hash_value||''',''C'');' as flush
FROM v$sqlarea
WHERE sql_id = '&SQLID';

exec dbms_shared_pool.purge ('0000000E3CEDFAB0,1528086390','C');
commit;
