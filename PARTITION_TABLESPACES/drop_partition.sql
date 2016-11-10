DECLARE
   exist_data   NUMBER;
   s            VARCHAR2 (100);
BEGIN
   SELECT NVL (COUNT (1), 0)
     INTO exist_data
     FROM SYMADM.SYM_JOURNAL PARTITION ("M201001");
   IF exist_data = 0
   THEN
      s := 'alter table SYMADM.SYM_JOURNAL drop partition M201001';
      ---EXECUTE IMMEDIATE s;
      DBMS_OUTPUT.put_line (s);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.FORMAT_ERROR_STACK);
END;
/
