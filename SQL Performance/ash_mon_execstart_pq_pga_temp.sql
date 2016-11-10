-- SQL monitor z ASH
DEFINE sqlid=8nu9k2a6wt8c4

--
@xiawr &sqlid NULL

--// SQL Plan line id a operation
SELECT   a.SQL_ID,
    a.SQL_EXEC_START,
    a.sql_plan_line_id,
    p.object_name,
    SQL_PLAN_OPERATION,
    COUNT(*),
    --PARTITION BY a.sql_id, a.sql_plan_hash_value
    ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY a.sql_id, a.SQL_EXEC_START) * 100, 1) "pct"
  FROM
--   GV$ACTIVE_SESSION_HISTORY
     dba_hist_active_sess_history a inner join DBA_HIST_SQL_PLAN p
          on (a.sql_id = p.SQL_ID
              and a.sql_plan_hash_value(+) = p.plan_hash_value
              and a.sql_plan_line_id(+) = p.id)
        WHERE 1     =1
        AND a.SQL_ID IN ('&sqlid')
--        and sql_plan_hash_value = '1747118681'
--        AND a.sample_time > sysdate - 7
--        AND SAMPLE_TIME BETWEEN TIMESTAMP'2015-02-15 23:30:00'
--                            AND TIMESTAMP'2015-02-16 09:00:00'
          --        AND SQL_PLAN_OPERATION = 'HASH JOIN'
        AND a.SQL_EXEC_START IS NOT NULL
  GROUP BY a.SQL_ID,
    a.SQL_EXEC_START,
    a.sql_plan_line_id, p.object_name,
    SQL_PLAN_OPERATION
  ORDER BY COUNT(*) DESC
  ;


-- MAX PQ slaves count, PGA, TEMP
COLUMN duration format A20
SELECT   SQL_ID,SQL_PLAN_HASH_VALUE,
    SQL_EXEC_START,
    MAX_SAMPLE-SQL_EXEC_START AS DURATION,
    MAX(PQ_COUNT),
    ROUND(max(MAX_PGA)/1048576) "PGA [MB]",
    ROUND(MAX(MAX_TEMP)/1048576) "TEMP [MB]"
  FROM
    (
SELECT   sample_time,
    SQL_ID,SQL_PLAN_HASH_VALUE,
    SQL_EXEC_START,
    sql_plan_line_id,
    sql_plan_operation,
    MAX(SAMPLE_TIME) over (partition BY SQL_EXEC_START) MAX_SAMPLE,
    COUNT(SAMPLE_TIME) OVER (PARTITION BY SAMPLE_TIME) PQ_COUNT,
    -- MAX mozno zamenit za SUM, pak je to pres vsechny PX procesy
    MAX(PGA_ALLOCATED) over (partition BY SAMPLE_TIME) MAX_PGA,
    MAX(TEMP_SPACE_ALLOCATED) OVER (PARTITION BY SAMPLE_TIME) MAX_TEMP
  FROM GV$ACTIVE_SESSION_HISTORY
--            FROM dba_hist_active_sess_history
  WHERE 1     =1
  AND SQL_ID IN ('&sqlid')
    --        AND SQL_PLAN_OPERATION = 'HASH JOIN'
  AND SQL_EXEC_START IS NOT NULL
  )
  GROUP BY SQL_ID,SQL_PLAN_HASH_VALUE,
    SQL_EXEC_START,
    MAX_SAMPLE
  ORDER BY sql_id,
    sql_exec_start;

-- max PGA alloc per minute interval během EOD na Colmanovi
select trunc(sample_time, 'MI') time,
       max(PGA)
from (
SELECT   sample_time,
    round(SUM(PGA_ALLOCATED)/1048576) PGA
  FROM dba_hist_active_sess_history
WHERE 1=1
-- AND sample_time between timestamp'2016-04-25 22:00:00'
--    and timestamp'2016-04-26 06:15:00'
  AND SQL_ID IN ('&sqlid')
--  AND SQL_EXEC_START IS NOT NULL
group by  sample_time
)
group by trunc(sample_time, 'MI')
order by 1;