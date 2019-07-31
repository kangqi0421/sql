--
-- autotask
--

select Client_Name, status, Service_Name
  from DBA_AUTOTASK_CLIENT
  where client_name = 'auto optimizer stats collection'
;

-- advisor
V$STATS_ADVISOR_RULES

select * from dba_autotask_operation;

select * from dba_autotask_client
  where client_name = 'auto optimizer stats collection'
;

-- Autotasks
SELECT *
FROM dba_autotask_job_history
WHERE client_name like '%stats%'
ORDER BY job_start_time desc;


-- zrušení automatického přepočtu statistik
BEGIN
  dbms_auto_task_admin.disable('auto optimizer stats collection',NULL,NULL);
END;
/


-- povolení sběru automatický statistik
BEGIN
  dbms_auto_task_admin.enable('auto optimizer stats collection',NULL,NULL);
END;
/

-- maintenance
https://jhdba.wordpress.com/2011/08/23/939/

Firstly I might as well stop the automatic mmon purging process until I have reduced data
exec dbms_stats.alter_stats_history_retention(-1);

-- vypis jobu autotasku pro automaticky sber statistik

SELECT *
FROM dba_autotask_job_history
WHERE client_name like '%stats%'
ORDER BY job_start_time;

select job_name,actual_start_date,log_date,run_duration
from   dba_scheduler_job_run_details
where JOB_NAME in (select JOB_NAME from dba_scheduler_job_log where additional_info like '%GATHER_STATS_PROG%')
order by ACTUAL_START_DATE desc;

--Set to DB service Auto Statistics Collection
BEGIN
  DBMS_AUTO_TASK_ADMIN.SET_CLIENT_SERVICE(
      client_name => 'auto optimizer stats collection',
      service_name => 'RTODS_RTOZA_ETL');
END;
/


-- change to ETL service, na zaklade hodnoty z v$services
BEGIN
  for rec in (select name from v$services where name like '%ETL')
  LOOP
    DBMS_AUTO_TASK_ADMIN.SET_CLIENT_SERVICE(
      client_name => 'auto optimizer stats collection',
      service_name => rec.name);
  END LOOP;
END;
/

