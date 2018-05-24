--
-- Scheduler jobs
--

- SRDC - DBMS_JOB : Checklist of Evidence to Supply (Doc ID 2115973.1)

-- DIAG TRACE
@srdc_db_job_diagnostic.sql "6"



-- running job
SELECT *
  from dba_scheduler_running_jobs
;

select * from v$session
  where sid = 780;

-- scheduler_attribute - log history
DBMS_SCHEDULER.SET_ATTRIBUTE

DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('log_history','90');

DBMS_SCHEDULER.PURGE_LOG(log_history => 3, which_log => 'JOB_LOG');



-- failure count > 0
SELECT   owner, job_name,  enabled,
         max_failures, failure_count
  FROM dba_scheduler_jobs
  WHERE failure_count > 0
    --AND max_failures IS NOT NULL
    ;

-- status jobu
SELECT *
--    owner, job_name, job_action, start_date, state, LAST_RUN_DURATION
  FROM dba_scheduler_jobs
where job_name like 'ORA$AT_OS_OPT_SY_46195';


-- Gather Stats
select job_name,actual_start_date,log_date,run_duration
from   dba_scheduler_job_run_details
where JOB_NAME in (select JOB_NAME from dba_scheduler_job_log where additional_info like '%GATHER_STATS_PROG%')
order by ACTUAL_START_DATE desc;

select * from DBA_OPTSTAT_OPERATIONS  where operation = 'gather_database_stats(auto)' order by start_time;

-- chyby z logu pro FAILED
SELECT *
--    cast(to_timestamp_tz(log_date) at local as date) log_date_local,
--    owner,
--    JOB_NAME,
--    status,
--    error#
  FROM DBA_SCHEDULER_JOB_RUN_DETAILS
  WHERE 1=1
--    and job_name LIKE 'CS_JOB%'
    and owner = 'IPX'
--    AND status <> 'SUCCEEDED'
  ORDER BY log_date DESC;

-- autotask history
SELECT *
FROM dba_autotask_job_history
WHERE 1=1
  and client_name like '%stats%'
  and job_name = 'ORA$AT_OS_OPT_SY_46195'
ORDER BY job_start_time;


/* interval day to seconds */
  SELECT job_name,
         req_start_date,
         actual_start_date,
         run_duration
    FROM dba_SCHEDULER_JOB_RUN_DETAILS
   WHERE job_name LIKE 'EIM_01_JOB'
         AND run_duration > TO_DSINTERVAL ('0 00:05:00')
ORDER BY log_date DESC;


