--// commit po 1000 øádkách //--

LOOP
    cnt := cnt + 1;
    IF ( mod( cnt, 1000 ) ) = 0 THEN          
       commit;
    END IF;
END LOOP;


--// BULK COLLECT po Limit //--
SELECT b.ID, DECODE(LENGTHB(b.request), 0, NULL, XMLQUERY(b.request RETURNING CONTENT)) AS request
  FROM TABLE(CAST(ptyp_xmltype_in AS ascbl.cobj_xmltype)) b;
BEGIN
  OPEN cur_payee;
  LOOP
  -- Fetch limited number of rows into collection
    FETCH cur_payee
    BULK COLLECT INTO ltab_dest_num, ltab_dest_xml
    LIMIT 1;
    EXIT WHEN cur_payee%NOTFOUND;
  END LOOP;
  CLOSE cur_payee;
END;
/


CREATE OR REPLACE procedure StatsDelete (pocetDni in number) as

--// cursor c1 definition --//
--// select snapshots for delete until $pocetDni --//
cursor c1 is
  select snap_id from stats$snapshot s
    where trunc(s.snap_time) < (sysdate - pocetDni)
    order by s.snap_id;
	
--// envinronment --//
  s varchar2(100);
  nRows number := 0;
  radekNaCommit number := 20;
  
--// procedure log	   --//
-- append log messages to log file --/
  procedure log(vMSG in varchar2) is
    hFD UTL_FILE.FILE_TYPE;
    begin
      hFD := utl_file.fopen('/oracle/admin/OSM0/log', 'stats_delete.log', 'a');
      utl_file.put_line(hFD, to_char(sysdate, 'Mon dd HH24:MI:SS') || ' ' || vMSG);
      utl_file.fclose(hFD);
    end log;
	
--// main --//

begin
  log('perfstat delete ' || user || ' started.');
  for rec in c1()
  loop
    s := 'delete from stats$snapshot where snap_id = ' || rec.snap_id;
	nRows := nRows + 1;
	dbms_output.put_line(s);
	log('snapd id ' || rec.snap_id || ' deleted');
	if nRows = radekNaCommit then
          nRows := 0;
          dbms_output.put_line('commit');
    end if;
  end loop;
  commit;
  log('perfstat delete ' || user || ' finished.');
end StatsDelete;
/
