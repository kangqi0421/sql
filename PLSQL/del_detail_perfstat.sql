--
-- Skript promaze vsechny snapshoty <pocetDni> zpet,
--   ktere nebyly porizeny v kazdou celou hodinu
--
-- <pocetDni>   ... pocet dni zpet
--
--

set verify off serveroutput on size 200000

define pocetDni = &&1

DECLARE
   TYPE NumTab IS TABLE OF stats$snapshot.snap_id%TYPE;
   snapshots      NumTab;
   radekCommit    NUMBER  := 20;
   radekCounter   NUMBER  := 0;
BEGIN
   /* nacti snap_id do pole snapshots */
   SELECT snap_id
   BULK COLLECT INTO snapshots
     FROM stats$snapshot
    WHERE snap_time < TRUNC (SYSDATE - &&pocetDni)
                  AND to_number(to_char(snap_time, 'mi'),'99') between 5 and 55;
   /* exception, pokud nenajdu zadne vhodne zaznamy */
   if snapshots.count = 0 then
      raise no_data_found;
   end if;

   /* promaz vsechny zaznamy s modulo radekCounter */
   FOR i IN snapshots.FIRST .. snapshots.LAST
   LOOP
      delete from stats$snapshot where snap_id = snapshots (i);
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
exception
   when no_data_found then
       dbms_output.put_line('No data found to update statistics.');
   when others then
      Raise_application_error(-20012, SQLERRM);
END;
/
