--
-- SQL trace
--

-- identifikace trace
alter session set tracefile_identifier='TO_JE_ONA';


-- REDIM SQL trace
BEGIN
  FOR rec in (select sid, serial# from v$session where username = 'REDIM_USER')
  LOOP
  DBMS_SYSTEM.set_ev(rec.sid,rec.serial#, 10046, 4, '');
  END LOOP;
END;
/

-- stop SQL trace
BEGIN
  FOR rec in (select sid, serial# from v$session where username = 'REDIM_USER')
  LOOP
  DBMS_SYSTEM.set_ev(rec.sid,rec.serial#, 10046, 0, '');
  END LOOP;
END;
/

---

EXEC DBMS_MONITOR.session_trace_enable(session_id=> 1118, serial_num=> 48059);

EXECUTE DBMS_SESSION.SESSION_TRACE_ENABLE(waits => TRUE, binds => TRUE);
EXECUTE DBMS_SESSION.SESSION_TRACE_DISABLE();
---

-- event 10046
oradebug setospid 24505

-- start trace
oradebug event 10046 trace name context forever, level 8

execute sys.dbms_system.set_ev(368,7409,10046,8,'');

DBMS_SESSION.SESSION_TRACE_ENABLE(waits => TRUE, binds => TRUE);

-- stop  trace
oradebug event 10046 trace name context off

execute dbms_system.set_ev(368,7409,10046,0,'');

dbms_session.session_trace_disable;

---
alter session set events '10046 trace name context forever, level 8';
alter session set events '10046 trace name context off';



-- sql trace
-- Oradebug
--

alter system set events='1000 trace name errorstack level 3';

alter system set events='1000 trace name errorstack off';

## ORA-01000: maximum open cursors exceeded

grep 'err=1000' *.trc

*** 2017-11-13 14:14:11.801

dbkedDefDump(): Starting a non-incident diagnostic dump (flags=0x0, level=3, mask=0x0)
----- Error Stack Dump -----
ORA-01000: maximum open cursors exceeded
----- SQL Statement (None) -----

 grep "Parent Cursor:  sql_id=33vmcj1yp1hj7" ODIDA_ora_43663.trc  | wc -l
