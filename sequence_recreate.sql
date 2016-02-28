/* recreate sequence */

DECLARE
  trt  NUMBER(20) := 0;
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE ascbl.bdt_mc_msg_seq';
  SELECT MAX(b.msg_id) + 1
    INTO trt
    FROM ascbl.bdt_mc_msg b;
  EXECUTE IMMEDIATE 'CREATE SEQUENCE ascbl.bdt_mc_msg_seq START WITH ' ||
                    trt ||
                    ' MAXVALUE 99999999999999999999 MINVALUE 100000000 NOCYCLE CACHE 1000 NOORDER';
  EXECUTE IMMEDIATE 'GRANT SELECT ON ascbl.bdt_mc_msg_seq TO ass24';
END;
/