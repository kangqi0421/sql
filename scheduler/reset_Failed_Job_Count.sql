SET serveroutput ON

set lin 180
col owner for a15
SELECT   owner, job_name,  enabled,
         max_failures, failure_count
  FROM dba_scheduler_jobs
  WHERE failure_count > 0
    --AND max_failures IS NOT NULL
    ;
	
BEGIN
  FOR rec IN
  (
    SELECT   owner,
        job_name,
        enabled,
        failure_count
      FROM dba_scheduler_jobs
      WHERE failure_count > 0
  )
  LOOP
    DBMS_SCHEDULER.DISABLE(NAME =>rec.owner||'.'||rec.job_name, FORCE => true );
    DBMS_SCHEDULER.ENABLE (NAME =>rec.owner||'.'||rec.job_name);
    IF rec.enabled = 'FALSE' THEN
      DBMS_SCHEDULER.DISABLE(NAME =>rec.owner||'.'||rec.job_name,FORCE =>true);
    END IF;
  END LOOP;
END;
/ 

SELECT   owner,
    job_name,
    enabled,
    max_failures,
    failure_count
  FROM dba_scheduler_jobs
  WHERE failure_count > 0
    --AND max_failures IS NOT NULL
    ;