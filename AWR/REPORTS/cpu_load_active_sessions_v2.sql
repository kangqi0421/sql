SELECT TO_CHAR(ROUND(CAST(end_time AS DATE), 'MI'), 'DD.MM.YYYY HH24:MI') "end_time",
       "NAME", "VALUE" 
FROM(
SELECT 
    ROUND(end_interval_time, 'MI') AS end_time,
    stat_name name, 
    to_number(value) AS VALUE
  FROM DBA_HIST_OSSTAT NATURAL 
  JOIN DBA_HIST_SNAPSHOT 
  WHERE stat_name         in (
           --'NUM_CPUS', 
           'NUM_CPU_CORES'
           ,'LOAD'
           )
    AND instance_number   = sys_context('USERENV', 'INSTANCE') 
    AND end_interval_time between  DATE'2014-05-12' and DATE'2014-05-13'
    --AND end_interval_time > TRUNC(sysdate - :DNI) 
UNION ALL 
SELECT  
    ROUND(end_interval_time, 'MI') AS end_time,
    metric_name name, 
    to_number(average) AS value 
  FROM dba_hist_sysmetric_summary NATURAL 
  JOIN DBA_HIST_SNAPSHOT 
  WHERE metric_name IN ( 
    'Average Active Sessions'
    --'Host CPU Utilization (%)', 
    --'Current OS Load' 
                       ) 
    AND instance_number   = sys_context('USERENV', 'INSTANCE') 
    AND end_interval_time between  DATE'2014-05-12' and DATE'2014-05-13'
    --AND end_interval_time > TRUNC(sysdate - :DNI) 
  ORDER BY end_time, name
)