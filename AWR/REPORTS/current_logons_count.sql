SELECT "END_TIME", "METRIC_NAME", "VALUE" FROM( 
SELECT   to_char(end_time,'dd.mm.yyyy hh24:mi') end_time,  
           metric_name,  
           to_number(maxval) AS value  
    FROM dba_hist_sysmetric_summary  
      where metric_name IN (   
            'Current Logons Count'  
            )  
        AND end_time > TRUNC(sysdate-:days)  
        AND instance_number = sys_context('USERENV', 'INSTANCE') 
ORDER by end_time      
)