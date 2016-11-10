-- kdy spustit ?

-- run job at night 22:00
-- define kdy_spustit = "trunc(sysdate)+interval'22' hour"
-- ihned
define kdy_spustit = sysdate

DECLARE 
    v_job_name VARCHAR2(30) := 'SYS.GATHER_UPGRADE_STATS';
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
                            dbms_stats.gather_dictionary_stats; 
                            DBMS_STATS.GATHER_FIXED_OBJECTS_STATS; 
                            dbms_stats.gather_system_stats(''NOWORKLOAD'');
                            dbms_stats.gather_system_stats(''INTERVAL'', interval=> 60);                      
                            END;',
        start_date      => &kdy_spustit ,
        auto_drop       => true,
        enabled	        => true,
        comments        => 'Gather system statistics before/after upgrade.');
END;  
/