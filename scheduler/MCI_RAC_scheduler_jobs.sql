-- load balance accross nodes
col job_name for a15
SELECT log_date, instance_id, job_name, status
 FROM DBA_SCHEDULER_JOB_RUN_DETAILS
where 1=1
--   AND  owner in ('IPX')
  AND log_date > sysdate - 1/24
order by log_date desc;

-- instance stickiness
-- pouze konkrétní job
define JOB_NAME=IPX.IPX_MONITORING
begin  
  dbms_scheduler.set_attribute_null(name => '&JOB_NAME' ,attribute=>'INSTANCE_ID');  
  dbms_scheduler.set_attribute(name => '&JOB_NAME' ,attribute=>'instance_stickiness', value=> TRUE);
  --dbms_scheduler.set_attribute(name => '&JOB_NAME' ,attribute=>'job_class',value=>'DEFAULT_JOB_CLASS'); 
end;  
/  

-- instance id, instance stickness -- reset to NULL pro všechny joby DBMAIN,DBEIM
BEGIN
   FOR rec
      IN (SELECT owner || '.' || job_name name,
                 job_action
            FROM dba_scheduler_jobs
           WHERE    owner in ('DBMAIN','DBEIM'))
   LOOP
    dbms_scheduler.set_attribute_null(name => rec.name ,attribute=>'INSTANCE_ID');  
    dbms_scheduler.set_attribute(name => rec.name ,attribute=>'instance_stickiness', value=> TRUE); 
   END LOOP;
END;
/

-- kontrola GOAL na SERVICE TIME pro service MCI_JOBS
select name, clb_goal, goal from dba_services where name like '%JOB%';

select owner, job_name name, state, job_class, INSTANCE_STICKINESS, INSTANCE_ID
  from dba_scheduler_jobs
 WHERE    owner in --('DBMAIN','DBEIM')
				   --('IPX')
 ;

-- MCI_JOBS, redefine default job class na service MCI_JOBS
DECLARE
  jobs_svc dba_services.name%TYPE;
BEGIN
  SELECT name INTO jobs_svc
    FROM dba_services
    WHERE name LIKE '%JOB%';
  dbms_scheduler.set_attribute(
    name => 'SYS."DEFAULT_JOB_CLASS"' 
    ,attribute=> 'service',
    value=>jobs_svc);
END; 
/ 

select job_class_name, service from dba_scheduler_job_classes; 

-- po zmìnì provést restart jobù nebo restart db
alter system set job_queue_processes = 0 scope=memory;
alter system set job_queue_processes = 8 scope=memory;
 
-- job class MCI_JOBS -nepoužito
BEGIN
 DBMS_SCHEDULER.create_job_class(
 job_class_name => 'MCI_JOBS_CLASS',
 service        => '&JOBS_SVC',
 comments => 'Job Class to serve MCI jobs');
END;
/

GRANT EXECUTE ON sys.MCI_JOBS_CLASS TO PUBLIC;
 
BEGIN
sys.dbms_scheduler.create_job(
job_class => 'MCI_JOBS_CLASS',
END;
/

-- TEST run job
exec dbms_scheduler.run_job('DBEIM.PREPAREEXPORT_JOB');