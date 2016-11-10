/* Formatted on 27.3.2012 10:42:59 (QP5 v5.163.1008.3004) */
DECLARE
   TYPE sestat_type IS TABLE OF v$sesstat%ROWTYPE
                          INDEX BY PLS_INTEGER;

   TYPE sesvalue_rec IS RECORD
   (
      ses_sid     v$sesstat.sid%TYPE,
      ses_value   v$sesstat.VALUE%TYPE
   );

   TYPE sesvalue_type IS TABLE OF sesvalue_rec
                            INDEX BY PLS_INTEGER;

   sleep_time   PLS_INTEGER := 2;

   s1           sestat_type;
   s2           sestat_type;
   diff         sesvalue_type;

   i            PLS_INTEGER;
   a            PLS_INTEGER;
   b            PLS_INTEGER;
   delta        PLS_INTEGER;

   PROCEDURE makeSnap (stats IN OUT sestat_type)
   IS
   BEGIN
        SELECT ses.sid, ses.statistic#, ses.VALUE
          BULK COLLECT INTO stats
          FROM v$sesstat ses, v$statname sn
         WHERE sn.statistic# = ses.statistic#
               AND LOWER (sn.name) LIKE LOWER ('redo size')
      ORDER BY ses.sid;
   END makeSnap;
BEGIN
   makeSnap (s1);
   -- sleep 5 sec
   DBMS_LOCK.sleep (sleep_time);
   makeSnap (s2);

   a := 1;
   b := 1;
   i := 1;

   WHILE (a <= s1.COUNT AND b <= s2.COUNT)
   LOOP
      CASE
         WHEN s1 (a).sid = s2 (b).sid
         THEN
            delta := s2 (i).VALUE - s1 (i).VALUE;

            IF delta >= 0
            THEN
               --diff.EXTEND;
               diff (i).ses_sid := s1 (a).sid;
               diff (i).ses_value := delta;

               i := i + 1;
            END IF;

            a := a + 1;
            b := b + 1;
         WHEN s1 (a).sid > s2 (b).sid
         THEN
            b := b + 1;
         WHEN s1 (a).sid < s2 (b).sid
         THEN
            a := a + 1;
      END CASE;
   END LOOP;

   DBMS_OUTPUT.put_line (i);

   FOR i IN 1 .. diff.COUNT
   LOOP
      DBMS_OUTPUT.put_line (diff (i).ses_sid || ' ' || diff (i).ses_value);
   END LOOP;
   
   FOR rec IN (  SELECT column_value col
                   FROM table(cast(diff as sesvalue_type)))
               loop 
               DBMS_OUTPUT.put_line(rec.col);
               end loop;
END;