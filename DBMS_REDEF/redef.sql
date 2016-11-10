set serveroutput on

variable n number
exec :n := dbms_utility.get_time

alter session force parallel dml parallel 4;
alter session force parallel query parallel 4;

begin
    dbms_redefinition.can_redef_table (
        'CBL',
        'LOG_ACTIONS',
         dbms_redefinition.cons_use_pk);
end;
/


begin
    dbms_redefinition.start_redef_table (
        'CBL',
        'LOG_ACTIONS',
        'LOG_ACTIONS_MOJE',
         null,
         dbms_redefinition.cons_use_pk
);
end;
/

DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('CBL', 'LOG_ACTIONS','LOG_ACTIONS_MOJE',
   DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/

BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('CBL', 'LOG_ACTIONS', 'LOG_ACTIONS_MOJE');
END;
/

exec dbms_output.put_line( (dbms_utility.get_time-:n) || ' hsecs to rebuild' );
