 select d.active, 

        (ratio_to_report(count(*)) over() *100) ||'%' PCT

  from fascor.fascor_document d 
group by d.active;

-- SQL Developer SQLDEV:GAUGE RATIO_TO_REPORT : MIN|MAX|MIN_THRESHOLD|MAX_THRESHOLD|VALUE
'SQLDEV:GAUGE:0:100:0:100:'||
      ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY a.sql_id, a.SQL_EXEC_START) * 100, 1) "pct"