-- SQL response time
select to_char(end_time,'dd.mm.yyyy hh24:mi') time, 
       metric_name,
       round( average * 10, 2) "Response Time (ms)"
     from dba_hist_sysmetric_summary
     where metric_name='SQL Service Response Time'
ORDER BY 1;

-- pro SQLDev Report
SELECT   END_TIME,
         decode(metric_name, 'Database CPU Time Ratio','CPU','Database Wait Time Ratio','Wait') metric,
         ROUND (average) value
  FROM dba_hist_sysmetric_summary
  WHERE METRIC_NAME     IN ('Database CPU Time Ratio','Database Wait Time Ratio')
    AND end_time     > TRUNC(SYSDATE - :dni)
  ORDER BY 1;

--// CPU to WAIT time ratio //--
WITH r1
     AS (SELECT END_TIME, ROUND (average) cpu
           FROM dba_hist_sysmetric_summary
          WHERE METRIC_NAME IN ('Database CPU Time Ratio')),
     r2
     AS (SELECT END_TIME, ROUND (average) wait
           FROM dba_hist_sysmetric_summary
          WHERE METRIC_NAME IN ('Database Wait Time Ratio'))
  SELECT a.end_time, cpu, wait
    FROM r1 a, r2 b
   WHERE a.end_time = b.end_time AND a.end_time > trunc(SYSDATE - &dni)
ORDER BY 1;