DECLARE
   pocetDni	   	  NUMBER  := 93;
   TYPE NumTab IS TABLE OF stats$snapshot.snap_id%TYPE;
   snapshots      NumTab;
   radekCommit    NUMBER  := 100;
   radekCounter   NUMBER  := 0;
BEGIN
   --select snap_id, snap_time
   SELECT snap_id
   BULK COLLECT INTO snapshots
     FROM stats$snapshot
    WHERE snap_time < TRUNC (SYSDATE - pocetDni)
                  AND to_number(to_char(snap_time, 'mi'),'99') between 5 and 55;
   IF SQL%NOTFOUND THEN
      Raise_application_error(-20011, 'nenalezena zadna data ke zpracovani');
   END IF;


   FOR i IN snapshots.FIRST .. snapshots.LAST
   LOOP
      delete from stats$snapshot where snap_id = snapshots (i);
      radekCounter := radekCounter + 1;

      IF radekCounter > radekCommit
      THEN
         commit;
         radekCounter := 0;
      END IF;
   END LOOP;

   COMMIT;
   dbms_output.put_line('snap id: ' || snapshots.first || ' - ' || snapshots.last);
   dbms_output.put_line(snapshots.count || ' rows deleted.');
EXCEPTION
   when no_data_found
        then null;
   WHEN OTHERS
   THEN
      Raise_application_error(-20012, SQLERRM);
END;
/
