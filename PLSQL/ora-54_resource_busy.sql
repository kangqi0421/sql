
DECLARE
   resource_busy   exception;
   pragma exception_init( resource_busy, -54 );
   --// deklarace pro bulk collect//--
   TYPE ownertab IS TABLE OF dba_tables.owner%TYPE;
   TYPE nametab IS TABLE OF dba_tables.table_name%TYPE;
   own   ownertab;
   tbl   nametab;
  
BEGIN
   SELECT owner, table_name
   BULK COLLECT INTO own, tbl
     FROM dba_tables
    WHERE owner = 'SYMBOLS' AND MONITORING = 'NO'
		  and temporary = 'N';

   --// raise exception when count(*) = 0 //--
   IF own.COUNT = 0
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   --// vlastni prepnuti na monitoring    //--
   FOR i IN own.FIRST .. own.LAST
   LOOP 
      BEGIN
        EXECUTE IMMEDIATE (   'ALTER TABLE ' || own (i)
                         || '.' || tbl (i)
                         || ' monitoring');
        DBMS_OUTPUT.put_line ('table ' || own (i) || '.' || tbl (i)
                            || ' altered.');
	  EXCEPTION	WHEN RESOURCE_BUSY THEN	 
	    --// ORA-54 chytni, zahod a pokracuj ve zpracovani  
        DBMS_OUTPUT.put_line (own(i)||'.'||tbl(i)
						 ||	' resource busy ORA-00054.');
	  END; 						
   END LOOP;
   
--// exception //--
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.put_line ('No data found to update monitoring on table.');
   WHEN OTHERS		  THEN
      raise_application_error (-20001, DBMS_UTILITY.FORMAT_ERROR_STACK);
END;
/
