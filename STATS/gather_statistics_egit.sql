set serveroutput on
DECLARE 
    v_window_name VARCHAR2(61) := 'EGIT_MAINTENANCE_WINDOW_GROUP';
    v_resource_plan VARCHAR2(30) := 'DEFAULT_MAINTENANCE_PLAN';
    v_repeat_interval VARCHAR2(255) := 'freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=22;byminute=0; bysecond=0';
    v_duration INTERVAL DAY TO SECOND := INTERVAL '60' MINUTE;
    v_priority VARCHAR2(30) := 'LOW';
    v_comments VARCHAR2(255) := 'EGIT WORKDAY maintenance window group';
BEGIN
    --
    begin
      DBMS_SCHEDULER.DROP_WINDOW (
        window_name=>v_window_name,
        force=>true);
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
    --
    DBMS_SCHEDULER.create_window (
     window_name     => v_window_name,
     resource_plan   => v_resource_plan,
     repeat_interval => v_repeat_interval,
     duration        => v_duration,
     window_priority => v_priority,
     comments        => v_comments
     );
 END;
/
DECLARE 
    v_job_name VARCHAR2(30) := 'SVC.GATHER_SYSTEM_STATS';
    v_window_name VARCHAR2(61) := 'SYS.EGIT_MAINTENANCE_WINDOW_GROUP';
BEGIN
    --
    begin
        dbms_scheduler.drop_job(v_job_name);
    exception when others then 
        dbms_output.put_line(SQLERRM);
    end;
    --
    DBMS_SCHEDULER.create_job (
        job_name        => v_job_name,
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN dbms_stats.gather_dictionary_stats; END;',
        schedule_name   => v_window_name,
        comments        => 'Gather system statistics.');
    DBMS_SCHEDULER.SET_ATTRIBUTE (
      name=>v_job_name,
      attribute=>'STOP_ON_WINDOW_CLOSE',
      value=>TRUE);
    --
    dbms_scheduler.enable(NAME=>v_job_name);
end;  
/
