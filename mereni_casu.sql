PL/SQL
======

DECLARE
	t_start 	TIMESTAMP;
	t_end 		TIMESTAMP;
BEGIN
	t_start := SYSTIMESTAMP;

	dbms_lock.sleep(5);  

	t_end := SYSTIMESTAMP;
	DBMS_OUTPUT.put_line(t_end - t_start);
END;
/




SQL*Plus:
=========

variable n number
exec :n := dbms_utility.get_time

PL/SQL procedure successfully completed.


ops$tkyte@ORA817DEV.US.ORACLE.COM> alter index t_idx3 rebuild nologging;

ops$tkyte@ORA817DEV.US.ORACLE.COM> exec dbms_output.put_line( 
(dbms_utility.get_time-:n) || ' hsecs to rebuild' );
1514 hsecs to rebuild

PL/SQL procedure successfully completed.
