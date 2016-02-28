-- drop trigger

define username = 'ETL_OWNER'

grant alter session to &username ;

DROP TRIGGER LogonTriggerSQLTrace;

-- v�etn� trace identifier
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

-- p�vodn� kr�tk� varianta:
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
