BEGIN
sys.dbms_scheduler.create_job(
job_name => 'SMS_SMID',
job_type => 'PLSQL_BLOCK',
job_action => '
BEGIN
  MERGE INTO cbloper.bdt_stor_act_sms_smid d
   USING (SELECT a.stored_tm, a.contract_id, a.acc_pfx_id, a.acc_no_id, a.bank_id,
       a.sms, a.sms_cc, b.sms AS oldphone
  FROM ascbl.bdt_stor_act_sms a, ascbl.bdt_usr_acc b
 WHERE a.contract_id = b.contract_id
   AND a.acc_pfx_id = b.acc_pfx_id
   AND a.acc_no_id = b.acc_no_id
   AND a.bank_id = b.bank_id) s
   ON (s.stored_tm = d.stored_tm AND s.contract_id = d.contract_id)
   WHEN NOT MATCHED THEN
      INSERT (d.stored_tm, d.contract_id, d.acc_pfx_id, d.acc_no_id,
              d.bank_id, d.sms, d.sms_cc, d.oldphone)
      VALUES (s.stored_tm, s.contract_id, s.acc_pfx_id, s.acc_no_id,
              s.bank_id, s.sms, s.sms_cc, s.oldphone);
   DELETE FROM cbloper.bdt_stor_act_sms_smid d
     where d.stored_tm < sysdate -7;
   COMMIT ;
END;
',
repeat_interval => 'FREQ=HOURLY',
start_date => sysdate,
job_class => '"DEFAULT_JOB_CLASS"',
comments => 'SMS_SMID',
auto_drop => FALSE,
enabled => TRUE);
END;
/


BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE('CBLOPER.SMS_SMID', 'job_action', 'BEGIN
  MERGE INTO cbloper.bdt_stor_act_sms_smid d
   USING (SELECT a.stored_tm, a.contract_id, a.acc_pfx_id, a.acc_no_id, a.bank_id,
       a.sms, a.sms_cc, b.sms AS oldphone
  FROM ascbl.bdt_stor_act_sms a, ascbl.bdt_usr_acc b
 WHERE a.contract_id = b.contract_id
   AND a.acc_pfx_id = b.acc_pfx_id
   AND a.acc_no_id = b.acc_no_id
   AND a.bank_id = b.bank_id) s
   ON (s.stored_tm = d.stored_tm AND s.contract_id = d.contract_id)
   WHEN NOT MATCHED THEN
      INSERT (d.stored_tm, d.contract_id, d.acc_pfx_id, d.acc_no_id,
              d.bank_id, d.sms, d.sms_cc, d.oldphone)
      VALUES (s.stored_tm, s.contract_id, s.acc_pfx_id, s.acc_no_id,
              s.bank_id, s.sms, s.sms_cc, s.oldphone);
   DELETE FROM cbloper.bdt_stor_act_sms_smid d
     where d.stored_tm < sysdate -7;
   COMMIT ;
END;
');
END;
/