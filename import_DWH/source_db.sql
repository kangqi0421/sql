--
-- source db DWHSRC2
--

alter system set streams_pool_size = 4G;

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
                            dbms_stats.lock_table_stats(null,''X$KCCLH'');
                            DBMS_STATS.GATHER_FIXED_OBJECTS_STATS();
                            END;',
        start_date      => sysdate,
        auto_drop       => true,
        enabled         => true,
        comments        => 'Gather system statistics after upgrade.');
END;
/
select JOB_NAME, state from dba_scheduler_jobs where job_name like 'GATHER_%_STATS';
