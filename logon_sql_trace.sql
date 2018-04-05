-- drop trigger

define username = 'TC'

grant alter session to &username ;

DROP TRIGGER LogonTriggerSQLTrace;

-- vèetnì trace identifier
CREATE OR REPLACE TRIGGER LogonTriggerSQLTrace AFTER logon ON DATABASE
  BEGIN
    IF ( USER like '&username') THEN
      EXECUTE immediate 'alter session set tracefile_identifier=''sql_trace''';
	  EXECUTE IMMEDIATE 'alter session set statistics_level=ALL';
	  EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
      EXECUTE immediate 'alter session set events ''10046 trace name context forever, level 12''';
      DBMS_SESSION.set_identifier ('SQL TRACE ENABLED VIA LOGIN TRIGGER');
	  --EXECUTE IMMEDIATE 'alter session set current_schema = PDB';
    END IF;
  END;
/

-- pùvodní krátká varianta:
/*
CREATE OR REPLACE TRIGGER LogonTriggerTrace
after logon on database
Begin
            if ( user like '&username') then
                DBMS_SESSION.SESSION_TRACE_ENABLE;
            End if;
End;
/
*/

-- Data Pump Trigger
CREATE OR REPLACE TRIGGER sys.set_dp_trace
AFTER LOGON ON DATABASE
DECLARE
  v_program v$session.program%TYPE;
  v_dyn_sql VARCHAR2(100);
  BEGIN
  SELECT substr(program, -5, 2)
  INTO v_program
  FROM v$session
  WHERE sid = (SELECT DISTINCT sid FROM v$mystat);
  IF v_program = 'DW' or v_program= 'DM' THEN
    EXECUTE IMMEDIATE 'alter session set tracefile_identifier = '||'DPTRC';
    EXECUTE IMMEDIATE 'alter session set statistics_level=ALL';
    EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
    EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
  END IF;
END;
/
