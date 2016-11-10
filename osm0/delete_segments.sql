DECLARE
   TYPE NumTab IS TABLE OF space$snapshots.snap_id%TYPE;
   snapshots      NumTab;
   pocetDni       NUMBER  := 93;
   radekCommit    NUMBER  := 20;
   radekCounter   NUMBER  := 0;
   timeUsed       NUMBER;
BEGIN
   timeUsed := dbms_utility.get_time;

   /* nacti snap_id do pole snapshots */
   SELECT snap_id
   BULK COLLECT INTO snapshots
     FROM space$snapshots
    WHERE started > TRUNC (SYSDATE - pocetDni);

   /* exception, pokud nenajdu zadne vhodne zaznamy */
   if snapshots.count = 0 then
      raise no_data_found;
   end if;

   /* promaz vsechny zaznamy s modulo radekCounter */
   FOR i IN snapshots.FIRST .. snapshots.LAST
   LOOP
      delete from space$dba_tables where snap_id = snapshots (i);
      delete from space$dba_indexes where snap_id = snapshots (i);
      radekCounter := radekCounter + 1;
      /* kazdych n-radek commit */
      IF MOD(radekCounter,radekCommit) = 0
      THEN
         commit;
         radekCounter := 0;
      END IF;
   END LOOP;

   COMMIT;

   /* vypis vysledek na STDOUT */
   dbms_output.put_line('snap id: ' || snapshots(snapshots.first) || ' - ' || snapshots(snapshots.last));
   dbms_output.put_line(snapshots.count || ' snapshots deleted.');
   dbms_output.put_line('time used: ' || (dbms_utility.get_time - timeUsed) / 100 || ' secs');

exception
   when no_data_found then
       dbms_output.put_line('No data found to update statistics.');
   when others then
      Raise_application_error(-20012, SQLERRM);
END;
/
