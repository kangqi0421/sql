--
-- SQL trace
--

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
