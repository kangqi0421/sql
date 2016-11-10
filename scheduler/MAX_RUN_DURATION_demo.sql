-- ======== run a second job after the first exceeds its time limit
 
-- create a table for output
create table job_output (a timestamp with time zone, b varchar2(1000));
 
-- add an event queue subscriber for this user's messages
exec dbms_scheduler.add_event_queue_subscriber('myagent')
 
-- create the first job
begin
 dbms_scheduler.create_job
   ( 'first_job', job_action =>
'insert into job_output values(systimestamp, ''first job begins'');
 dbms_lock.sleep(65);
 insert into job_output values(systimestamp, ''first job ends'');',
    job_type => 'plsql_block',
    enabled => false ) ;
 dbms_scheduler.set_attribute
    ( 'first_job' , 'max_run_duration' , interval '60' second);
end;
/
 
-- create a simple second job that runs after the first has
-- exceeded its max_run_duration
begin
  dbms_scheduler.create_job('second_job',
                            job_type=>'plsql_block',
                            job_action=>
    'insert into job_output values(systimestamp, ''second job runs'');',
                            event_condition =>
   'tab.user_data.object_name = ''FIRST_JOB'' and
    tab.user_data.event_type = ''JOB_OVER_MAX_DUR''',
                            queue_spec 
=>'sys.scheduler$_event_queue,myagent',
                            enabled=>true);
end;
/
 
-- enable the first job so it starts running
exec dbms_scheduler.enable('first_job')
 
exec dbms_lock.sleep(65)

select * from job_output