--
-- gather_schema_stats
--

define schema = '&1'

BEGIN
  for rec in (
      SELECT username from dba_users WHERE username IN ('&schema')
             )
  LOOP
    dbms_scheduler.create_job(
      job_name => 'STAT_'||rec.username,
      JOB_TYPE => 'PLSQL_BLOCK',
      job_action => 'BEGIN dbms_stats.gather_schema_stats('''||rec.username||'''); END;',
      start_date => sysdate,
      repeat_interval => NULL,
      auto_drop => TRUE,
      enabled => true);
  END LOOP;
END;
/
