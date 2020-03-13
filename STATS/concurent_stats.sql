select dbms_stats.get_prefs('CONCURRENT') pref from dual;

exec DBMS_STATS.SET_GLOBAL_PREFS('CONCURRENT','TRUE');

grant CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE to RDB;
grant CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE to RDB_NCRA;
grant CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE to RDB_PLAB;


-- pøepoèet apliakèních schmeat RDB
BEGIN
  DBMS_STATS.SET_GLOBAL_PREFS('CONCURRENT','TRUE');
  for c in (select username from dba_users where username in ('RDB', 'RDB_PLAB', 'RDB_NCRA'))
  loop
     dbms_stats.gather_schema_stats(c.username);
  end loop;
END;
/


ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE'; 
alter session set NLS_TERRITORY = 'CZECH REPUBLIC'; 

begin
dbms_scheduler.create_job(
  job_name => 'RDB_STATS',
  job_type => 'PLSQL_BLOCK',
  job_action => 'BEGIN
  for c in (select username from dba_users where username in (''RDB'', ''RDB_PLAB'', ''RDB_NCRA''))
  loop
     dbms_stats.gather_schema_stats(c.username);
  end loop;
END;',
  start_date => timestamp'2012-07-02 23:30:00',
  repeat_interval => NULL,
  auto_drop => TRUE,
  enabled => TRUE);
END;
/