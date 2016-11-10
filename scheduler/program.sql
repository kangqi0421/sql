begin  
  dbms_scheduler.set_job_argument_value(job_name          => 'DBMAIN.GATHERPARTSTATS_JOB',
                                        argument_position => 3,
                                        argument_value    => 'SYSDATE');
  dbms_scheduler.set_job_argument_value(job_name          => 'DBMAIN.GATHERPARTSTATS_JOB',
                                        argument_position => 4,
                                        argument_value    => 'SYSDATE');
end;                                        


select * from dba_scheduler_job_args
where job_name = 'GATHERPARTSTATS_JOB'

dbms_scheduler.create_job(job_name      => 'DBMAIN.GATHERPARTSTATS_JOB',
                            program_name  => 'DBMAIN.GATHERPARTSTATS_01_PRG',
                            schedule_name => 'DBMAIN.GATHERPARTSTATS_SCH',
                            auto_drop     => FALSE,
                            comments      => 'Gather Partition Stats job - noon.');

begin
DBMS_SCHEDULER.DROP_PROGRAM_ARGUMENT (
   program_name  => 'DBMAIN.GATHERPARTSTATS_01_PRG',
   argument_position => 3,
   argument_name => 'GATHERPARTSTATS_ARG3');
end;   

begin
DBMS_SCHEDULER.DEFINE_METADATA_ARGUMENT (
   program_name  => 'DBMAIN.GATHERPARTSTATS_01_PRG',
   metadata_attribute  =>    'job_start',
  argument_position   =>     4,
  argument_name => 'GATHERPARTSTATS_ARG4');
end;  


---

begin
DBMS_SCHEDULER.DISABLE('SYS.MOVE_TO_STAGE');
end;
/

begin
DBMS_SCHEDULER.ENABLE('SYS.MOVE_TO_STAGE');
end;
/