/* Formatted on 9.8.2011 15:52:14 (QP5 v5.163.1008.3004) */
DECLARE
   TYPE t_aeprocess_TAB IS TABLE OF aeprocess.PROCESSID%TYPE;

   l_aeprocess_TAB   t_aeprocess_TAB;

   CURSOR cr
   IS
      SELECT processid
        FROM aeprocess
       WHERE processstate IN (3, 4) ... ;

   BATCH             INTEGER := 500; -- Number of precesses deleted in one batch
BEGIN
   OPEN cr;

   LOOP
      FETCH cr
      BULK COLLECT INTO l_aeprocess_TAB
      LIMIT BATCH;

      FORALL i IN 1 .. l_aeprocess_TAB.COUNT
         delete from BPMS.AEPROCESSLOGDATA 
               WHERE PROCESSID = l_aeprocess_TAB (i);

      COMMIT;
      EXIT WHEN cr%NOTFOUND;
   END LOOP;

   CLOSE cr;

   COMMIT;                                                    -- final commit;
END;
/