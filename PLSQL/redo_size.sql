DECLARE
   TYPE sestat_type IS TABLE OF v$sesstat%ROWTYPE
                          INDEX BY PLS_INTEGER;
    -- preddefinovany typ DBMS_DEBUG_VC2COLL
   TYPE sesvalue_type IS TABLE OF SYS.DBMS_DEBUG_VC2COLL;
   --INDEX BY PLS_INTEGER;

   sleep_time    PLS_INTEGER := 5;

   -- prvni snap
   s1            sestat_type;
   -- druhy snap
   s2            sestat_type;
   -- tabulka rozdilnych hodnot
   diff          SYS.dbms_debug_vc2coll := NEW sys.dbms_debug_vc2coll ();
   diff_sorted   SYS.dbms_debug_vc2coll := NEW sys.dbms_debug_vc2coll ();

   i             PLS_INTEGER;
   a             PLS_INTEGER;
   b             PLS_INTEGER;
   delta         PLS_INTEGER;

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

            IF delta > 0
            THEN
               diff.EXTEND;
               diff (i) := delta || ' sid:' || s1 (a).sid;

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

   -- pocet nalezenych hodnot
   DBMS_OUTPUT.put_line (i);

   -- sortovani DIFF hodnot, top 5 vybrat - zatim nefunguje
   --SELECT column_name
   --  bulk collect INTO DIFF_SORTED
   --  FROM (
   SELECT CAST (MULTISET (  SELECT *
                              FROM TABLE (diff)
                          ORDER BY 1 DESC) AS SYS.DBMS_DEBUG_VC2COLL)
     INTO diff
     FROM DUAL;

   --)
   --WHERE ROWNUM <= 5;

   FOR i IN 1 .. diff.COUNT
   LOOP
      DBMS_OUTPUT.put_line (diff (i));
   END LOOP;
END;