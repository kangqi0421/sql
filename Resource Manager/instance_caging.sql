http://joordsblog.vandenoord.eu/2012/01/instance-caging-managing-multiple.html

--// nutno povolit resource manager //--
alter system set resource_manager_plan = DEFAULT_PLAN;

-- lepší použít resource manager od p. Tyleho, ale když není, tak není ...

--// omezeni poctu dostupnych CPU threadu //--
ALTER SYSTEM SET cpu_count = 4;

-- Instance Caging validation
select value from v$parameter where name ='cpu_count'
  and (isdefault='FALSE' or ismodified != 'FALSE');

select name from v$rsrc_plan where cpu_managed='ON' and is_top_plan='TRUE';

-- Monitoring Throttling
select name, active_sessions, execution_waiters, 
       consumed_cpu_time, cpu_wait_time,
       yields 
   from v$rsrc_consumer_group;

-- Monitoring history   
SELECT
    inst_id, begin_time, consumer_group_name, 
    cpu_consumed_time, cpu_wait_time, num_cpus, 
    running_sessions_limit, avg_running_sessions,  avg_waiting_sessions, avg_cpu_utilization
  FROM gv$rsrcmgrmetric_history
 where consumer_group_name in ('OTHER_GROUPS')
  and inst_id = 1
  ORDER BY begin_time; 
  
-- DBA_HIST
SELECT  *
--        end_interval_time, instance_number, consumer_group_name, 
--        consumed_cpu_time, yields
  FROM DBA_HIST_RSRC_CONSUMER_GROUP NATURAL
	   JOIN dba_hist_snapshot
  WHERE  consumer_group_name in ('OTHER_GROUPS')
    AND instance_number = 1
  ORDER BY end_interval_time desc;  
  
-- event 
SELECT TRUNC(sample_time), COUNT(*)
  FROM dba_hist_active_sess_history
 WHERE event LIKE 'resmgr:cpu quantum'
GROUP BY TRUNC(sample_time)
ORDER BY 1;  
