column pname format a20
SELECT pname, pval1
  FROM aux_stats$
WHERE sname = 'SYSSTATS_MAIN';

-- kdy spustit ?
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
                            -- dictionary stats se sbiraji pres AUTOSTATS
                            DBMS_STATS.GATHER_DICTIONARY_STATS (); 
                            -- fixed se nesbiraji pres AUTOSTATS
                            DBMS_STATS.GATHER_FIXED_OBJECTS_STATS();
                            dbms_stats.delete_system_stats();
                            dbms_stats.gather_system_stats(''NOWORKLOAD'');
                            -- tohle nechat až na uzaverku
                            --dbms_stats.gather_system_stats(''INTERVAL'', interval=> 60);                      
                            END;',
        start_date      => sysdate,
        auto_drop       => true,
        enabled         => true,
        comments        => 'Gather system statistics after migration');
END;  
/

select JOB_NAME, state from dba_scheduler_jobs where job_name like 'GATHER_%_STATS';
