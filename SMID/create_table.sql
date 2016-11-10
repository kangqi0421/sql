/* Formatted on 2007/04/24 13:10 (Formatter Plus v4.8.8) */
DROP TABLE cbloper.bdt_stor_act_sms_smid;

CREATE TABLE cbloper.bdt_stor_act_sms_smid
TABLESPACE users_ts
AS
SELECT t.stored_tm, t.contract_id, t.acc_pfx_id, t.acc_no_id, t.bank_id, t.sms, t.sms_cc
FROM cbl.bdt_stor_act_sms t
WHERE 1 = 0;

ALTER TABLE cbloper.bdt_stor_act_sms_smid
 ADD CONSTRAINT bdt_stor_act_sms_smid_pk
 PRIMARY KEY
 (stored_tm, contract_id);

COMMENT ON TABLE cbloper.bdt_stor_act_sms_smid IS 'Historicka data pro p. Smida.';

ALTER TABLE CBLOPER.BDT_STOR_ACT_SMS_SMID ADD (OLDPHONE  VARCHAR2(30 BYTE));


-- MERGE
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
