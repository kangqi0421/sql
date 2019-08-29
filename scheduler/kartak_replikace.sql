
connect CSBREP

-- CTR_TAB FULL
begin dbms_scheduler.drop_job(job_name=>'REPPKG_CTR_TAB_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_CTR_TAB_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_CTR_TAB.RUN_FULL_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- DEVICE_RESP FULL
begin dbms_scheduler.drop_job(job_name=>'REPPKG_DEVICE_RESP_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_DEVICE_RESP_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_DEVICE_RESP.RUN_FULL_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- DEF_TAB FULL
begin dbms_scheduler.drop_job(job_name=>'REPPKG_DEF_TAB_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_DEF_TAB_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_DEF_TAB.RUN_FULL_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- CURR_TRANS PK
begin dbms_scheduler.drop_job(job_name=>'REPPKG_CURR_TRANS_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_CURR_TRANS_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_CURR_TRANS.RUN_PK_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- IFS8583POS_BATCH_TAB PK
begin dbms_scheduler.drop_job(job_name=>'REPPKG_IFS8583POS_BATCH_TAB_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_IFS8583POS_BATCH_TAB_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_IFS8583POS_BATCH_TAB.RUN_PK_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- EMV_TAB PK
begin dbms_scheduler.drop_job(job_name=>'REPPKG_EMV_TAB_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_EMV_TAB_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_EMV_TAB.RUN_PK_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- USEQ_TAB PK
begin dbms_scheduler.drop_job(job_name=>'REPPKG_USEQ_TAB_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_USEQ_TAB_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_USEQ_TAB.RUN_PK_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- FM_TRANS PK
begin dbms_scheduler.drop_job(job_name=>'REPPKG_FM_TRANS_JOB', force=>true); end;
/

begin
dbms_scheduler.create_job(
   job_name => 'REPPKG_FM_TRANS_JOB',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE ri INTEGER; ru INTEGER; rm INTEGER; err_code rep_errors.err_code%TYPE; err_text rep_errors.err_text%TYPE; begin REPPKG_FM_TRANS.RUN_PK_REPLICATION(ri, ru, rm, err_code, err_text); end;',
   start_date => sysdate,
   repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

