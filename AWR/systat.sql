---
SYSTAT
---

 - redo size
 - physical read total bytes
 - physical write total bytes
 - bytes received via SQL*Net from client
 - bytes sent via SQL*Net to client
 - CPU used by this session
 - user commit

SELECT STAT_ID, STAT_NAME
  FROM DBA_HIST_STAT_NAME
   WHERE LOWER(STAT_NAME) LIKE LOWER('%&1%')
  ORDER BY stat_name;

ALTER SESSION SET nls_date_format = 'dd.mm.yyyy hh24:mi';
ALTER SESSION SET NLS_TERRITORY = "CZECH REPUBLIC";

select CAST(end_interval_time AS DATE) "time",
       SNAP_ID, 
       STAT_NAME,  
       ROUND (
          delta_value
          / to_number(  EXTRACT (DAY FROM delta_time) * 86400
             + EXTRACT (HOUR FROM delta_time) * 3600
             + EXTRACT (MINUTE FROM delta_time) * 60
             + EXTRACT (SECOND FROM delta_time)),
          1)                                          "value"
  from (  select SNAP_ID, 
                 END_INTERVAL_TIME, 
                 stat_name,
                 END_INTERVAL_TIME
                 - LAG (END_INTERVAL_TIME, 1) over (partition by STAT_NAME order by SNAP_ID)    DELTA_TIME,
                 VALUE - LAG (VALUE, 1, VALUE) OVER (PARTITION BY stat_name ORDER BY snap_id)   delta_value
            FROM dba_hist_sysstat NATURAL JOIN dba_hist_snapshot
           WHERE instance_number = sys_context('USERENV', 'INSTANCE') 	-- instance number
		AND stat_name = 'bytes received via SQL*Net from client'   			-- user commits
		--AND end_interval_time > sysdate - 4/24		-- posledni 4 hodiny
        ORDER BY snap_id ASC);


---
SYS_TIME_MODEL
---

--// failed parse elapsed time //--
SELECT   TO_CHAR (s.end_interval_time, 'dd.mm.yyyy hh24:mi') "date",
         (VALUE - LAG (VALUE, 1) OVER (ORDER BY VALUE))/1000000 "failed parse time [s]"
    FROM DBA_HIST_SYS_TIME_MODEL e, DBA_HIST_SNAPSHOT s
   WHERE e.snap_id = s.snap_id
     AND e.instance_number = s.instance_number
       AND e.instance_number = 1
       AND e.stat_name = 'failed parse elapsed time'
ORDER BY s.end_interval_time DESC;
