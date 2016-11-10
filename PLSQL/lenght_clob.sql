/* Formatted on 2007/08/27 10:38 (Formatter Plus v4.8.8) */
DECLARE
   lxml_data      XMLTYPE;
   lclob_data     CLOB;
   vclob_length   NUMBER;
BEGIN
   FOR reclat IN (SELECT message_id, DATA
                    FROM SYS.test_log_trn)
   LOOP
      lxml_data := reclat.DATA;
      lclob_data := lxml_data.getclobval ();
      vclob_length := DBMS_LOB.getlength (lclob_data);

      UPDATE SYS.test_log_trn
         SET clob_length = vclob_length
       WHERE message_id = reclat.message_id;
   END LOOP;
END;
/