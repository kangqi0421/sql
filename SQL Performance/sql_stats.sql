-- SQL statistiky --

-- times in MICROSECONDS converted TO SECONDS -- /1000000

--
select * from dba_hist_sqltext where sql_text like 'select distinct b.CR_DR_IND%';
select * from dba_hist_sqltext where sql_id = :sqlid;

define sqlid = f5stk73u70gcu

select * from DBA_HIST_SQLSTAT where sql_id = '&sqlid';

-- DBA_HIST_SQLSTAT
SELECT
    sql_id, FORCE_MATCHING_SIGNATURE, begin_interval_time,
    elapsed_time_delta/NULLIF(executions_delta,0)     elapsed,
    cpu_time_delta/NULLIF(executions_delta,0)         cpu_time,
	  ROWS_PROCESSED_DELTA/NULLIF(executions_delta,0)   rows_per_exec,
    executions_delta                                  executions
  FROM
      DBA_HIST_SQLSTAT NATURAL JOIN dba_hist_snapshot
  WHERE 1=1
     -- and begin_interval_time between timestamp'2014-07-11 10:00:00'
            --                  and timestamp'2014-07-11 12:00:00'
      and sql_id in ('&sqlid')
  ORDER by begin_interval_time
;


-- long queries over elapsed time ;-)
WITH
  query AS
  (
    SELECT
      sql_id,
      ROUND(SUM(elapsed_time_delta/1000000)/NULLIF(SUM(executions_delta),0))  elapsed,
      ROUND(SUM(cpu_time_delta /1000000)/NULLIF(SUM(executions_delta),0))     cpu_time,
	  ROUND(SUM(ROWS_PROCESSED_DELTA)/NULLIF(SUM(executions_delta),0))     rows_processed,
      SUM(executions_delta)                                                   executions
    FROM
      DBA_HIST_SQLSTAT NATURAL JOIN dba_hist_snapshot
    WHERE
      begin_interval_time > sysdate - 1
    GROUP BY sql_id
    ORDER BY 2 DESC NULLS LAST
  )
SELECT
  sql_id,  elapsed,  cpu_time,  executions
FROM query
WHERE
  elapsed > 60*10  -- 10 min over limit
;

-- max pga allocated for sqlid
SELECT   a.SQL_ID, max(a.pga_allocated)/1048576
  FROM
     dba_hist_active_sess_history a
        WHERE 1     =1
        AND a.SQL_ID IN ('&sqlid')
  GROUP BY a.SQL_ID
  ORDER BY COUNT(*) DESC
  ;

-- SQL stats, porovnání počtu disk reads vůči celkovému provozu v DB pro konrétní SQL
  SELECT c.begin_interval_time,
         NVL (reads_arm, 0) AS arm_reads,
         reads_total,
         ROUND (NVL (reads_arm, 0) / reads_total * 100) "pct"
    FROM    (   (SELECT snap_id,
                        VALUE - LAG (VALUE, 1) OVER (ORDER BY snap_id)
                           AS reads_total
                   FROM DBA_HIST_SYSSTAT
                  WHERE stat_name LIKE 'physical reads') a
             LEFT JOIN
                (SELECT snap_id, ROUND (sum(disk_reads_delta)) AS reads_arm
                   FROM dba_hist_sqlstat
                  WHERE sql_id in (&1) group by snap_id ) b
             ON a.snap_id = b.snap_id)
         JOIN
            dba_hist_snapshot c
         ON a.snap_id = c.snap_id
ORDER BY 1;


select  round(sum(cpu_time_delta/1000000)) d15_cpu_time_secs
           ,round(sum(iowait_delta/1000000)) d15_iowait_secs
           ,round(sum(elapsed_time_delta/1000000)) d15_elapsed_time_secs
           from  dba_hist_sqlstat
  where  snap_id between min_snap and max_snap
    and sql_id in ('&sqlid');