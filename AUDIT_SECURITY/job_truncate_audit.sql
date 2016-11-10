BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name                 =>  'truncate_audit', 
   job_type                 =>  'PLSQL_BLOCK',
   job_action               =>  'begin execute immediate ''TRUNCATE TABLE sys.aud$''; end;',
   enabled                  =>   true,
   comments                 =>  'truncate sys.aud$', 
   repeat_interval          =>  'FREQ=HOURLY; INTERVAL=1');
END;
/