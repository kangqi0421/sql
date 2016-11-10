--// change job action from MIGR to MIGR_RC //--
BEGIN
   FOR rec
      IN (SELECT owner || '.' || job_name name,
                 job_action
            FROM dba_scheduler_jobs
           WHERE     owner = 'ARS_DB_MIGRATION'
                 AND state = 'DISABLED'
                 AND job_name LIKE 'MIGR$%')
   LOOP
      DBMS_SCHEDULER.SET_ATTRIBUTE (name => rec.name, attribute   => 'job_action',
            VALUE => REPLACE (rec.job_action, 'MIGR.', 'MIGR_RC.'));
   END LOOP;
END;
