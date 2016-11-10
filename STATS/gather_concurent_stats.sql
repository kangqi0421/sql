-- database stats concurrent
select dbms_stats.get_prefs('concurrent') from dual;
show parameter job_queue_processes

declare
  
begin
  dbms_stats.set_global_prefs('CONCURRENT','TRUE');
  dbms_stats.gather_database_stats;
  dbms_stats.set_global_prefs('CONCURRENT','FALSE');
end;
/

select dbms_stats.get_prefs('concurrent') from dual;

DECLARE 
    v_job_name VARCHAR2(128) := 'SYS.GATHER_DATABASE_STATS';
BEGIN
    --
    begin
        dbms_scheduler.drop_job(v_job_name, true);
    exception when others then null;
    end;
    --
    DBMS_SCHEDULER.create_job (
        job_name        => v_job_name,
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                              dbms_stats.set_global_prefs(''CONCURRENT'',''TRUE'');
                              dbms_stats.gather_database_stats;
                              dbms_stats.set_global_prefs(''CONCURRENT'',''FALSE'');
                            END;',
        start_date      => sysdate,
        auto_drop       => true,
        enabled	        => true,
        comments        => 'Gather database concurrent statistics after upgrade.');
END;  
/

select JOB_NAME, state from dba_scheduler_jobs where job_name = 'GATHER_DATABASE_STATS';