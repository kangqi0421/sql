--
-- DBMS_SCHEDULER
--

ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE';
alter session set NLS_TERRITORY = 'CZECH REPUBLIC';

-- GRANT
define username = PRODUCTION_TESTCENTRE_DB

GRANT CREATE JOB TO &username;

-- 12.1. Setting Chain Privileges
BEGIN
  DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE(DBMS_RULE_ADM.CREATE_RULE_OBJ, '&username');
  DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE(DBMS_RULE_ADM.CREATE_RULE_SET_OBJ, '&username');
  DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE(DBMS_RULE_ADM.CREATE_EVALUATION_CONTEXT_OBJ, '&username');
END;
/

-- drop ARM jobs
begin
  dbms_scheduler.drop_job(job_name=>'ARM_CLSYS.ARM_CLIENT_JOB', force=>True);
  dbms_scheduler.drop_job(job_name=>'ARM_CLSYS.ARM_CLIENT_CLEANUP_JOB', force=>True);
end;
/


BEGIN
   FOR rec IN (
     SELECT owner ||'.'|| job_name name
            FROM dba_scheduler_jobs
           WHERE     owner = 'DWA_OWNER'
                 --AND state = 'DISABLED'
                 --AND job_name LIKE 'MIGR$%'
                 )
   LOOP
      DBMS_SCHEDULER.drop_job (job_name => rec.name, force=>True);
   END LOOP;
END;
/


-- TEST job, sleep 10 sec
begin
dbms_scheduler.create_job(
  job_name => 'TEST',
  JOB_TYPE => 'PLSQL_BLOCK',
  job_action => 'BEGIN
      dbms_lock.sleep(10);
      END;',
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


-- instance_stickiness on INST 2 - nahra�eno za DB service MCI_JOBS
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


-- DBA_SCHEDULER_GLOBAL_ATTRIBUTE
select  ATTRIBUTE_NAME, VALUE
from   DBA_SCHEDULER_GLOBAL_ATTRIBUTE;
select  *
from   dba_scheduler_job_classes
where job_class_name in (select job_class
                                       from   dba_scheduler_jobs
                                       where job_name=upper('&jobname'));