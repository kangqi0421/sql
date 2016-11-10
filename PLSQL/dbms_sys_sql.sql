DECLARE
   cursorUser_id   INTEGER;
   cursorPointer   INTEGER := sys.DBMS_SYS_SQL.open_cursor ();
   cursorQuery     VARCHAR2 (100)
      := 'DELETE FROM asdon.log_pmwd_request b WHERE b.request_tm < SYSDATE - 92';
BEGIN
   SELECT user_id
     INTO cursorUser_id
     FROM dba_users
    WHERE username = 'DBMAIN';

   DBMS_SYS_SQL.PARSE_AS_USER (cursorPointer,
                               cursorQuery,
                               DBMS_SQL.native,
                               cursorUser_id);
   DBMS_OUTPUT.PUT_LINE (DBMS_SYS_SQL.EXECUTE (cursorPointer));
   DBMS_SYS_SQL.CLOSE_CURSOR (cursorPointer);
END;
/