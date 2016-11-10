ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE'; 
alter session set NLS_TERRITORY = 'CZECH REPUBLIC'; 

/* sleep job + auto drop po jeho skonèení */ 
begin
  dbms_scheduler.drop_job(job_name => 'TEST');
end;
/

-- TEST job, sleep 10 sec
begin
dbms_scheduler.create_job(
  job_name => 'TEST',
  JOB_TYPE => 'PLSQL_BLOCK',
  job_action => 'BEGIN dbms_lock.sleep(10); END;',
  start_date => sysdate,
  repeat_interval => NULL,
  auto_drop => true,
  enabled => true);
end;
/

-- repeat job every 1 minute
begin
dbms_scheduler.create_job(
   job_name => 'TEST',
   job_type => 'PLSQL_BLOCK',
   job_action => 'BEGIN dbms_lock.sleep(1); END;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/


-- instance_stickiness on INST 2 - nahraženo za DB service MCI_JOBS
begin  
  dbms_scheduler.set_attribute(name => 'TEST' ,attribute=>'INSTANCE_ID', value=> 2);  
  dbms_scheduler.set_attribute(name => 'TEST' ,attribute=>'instance_stickiness', value=> TRUE); 
end;  
/  

exec dbms_scheduler.run_job('TEST');

-- GATHER database stats
begin
dbms_scheduler.create_job(
  job_name => 'DbStats',
  JOB_TYPE => 'PLSQL_BLOCK',
  job_action => 'BEGIN dbms_stats.gather_database_stats(); END;',
  start_date => sysdate,
  repeat_interval => NULL,
  auto_drop => TRUE,
  enabled => true);
end;
/


-- repeat job 
begin
dbms_scheduler.create_job(
   job_name => 'TEST',
   job_type => 'PLSQL_BLOCK',
   job_action => 'BEGIN dbms_lock.sleep(1); END;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=10',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/


--// auto restart //--
enabled => false;

dbms_scheduler.set_attribute(NAME => job_name, ATTRIBUTE => 'restartable', VALUE => TRUE);
dbms_scheduler.enable (job_name);

--// max_run_duration //--
dbms_scheduler.set_attribute ( job_name, 'max_run_duration' , interval '60' second);

-- log_history - the length of time scheduler logs are kept in dayes
DBMS_SCHEDULER.set_scheduler_attribute (attribute => 'log_history',value     => 60);
