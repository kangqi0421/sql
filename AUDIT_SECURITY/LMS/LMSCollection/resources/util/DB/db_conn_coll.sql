SET ECHO OFF
SET TERMOUT OFF
SET DEFINE ON
SET MARKUP HTML OFF
SET TAB OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET PAGESIZE 5000
SET LINESIZE 300
SET SERVEROUTPUT ON
SET SERVEROUTPUT UNLIMITED
SET FEEDBACK OFF
SET VERIFY OFF

SET TERMOUT ON
define EXPECTED_PDB=0
define EXPECTED_PDB=&1

PROMPT db_conn_coll.sql ...
SET TERMOUT OFF

spool temp2.sql
-- Check CDB/PDB BEGIN
DECLARE
  ERR_C             NUMBER         := null;
  ERR_M             VARCHAR2(500)  := '';
  EBS_SCHEMA        VARCHAR2(100)  := '';
  PDB_EXP_          VARCHAR2(100)  := '&&EXPECTED_PDB';
  PDB_CRT_          VARCHAR2(100)  := '&&EXPECTED_PDB';
BEGIN

  BEGIN
    -- Check if this is the expected container (in CDBs)
    select max(sys_context('USERENV', 'CON_NAME')) C1
      into PDB_CRT_
      from V$PARAMETER
      where NAME = 'enable_pluggable_database'
        and VALUE = 'TRUE'
        and '&&EXPECTED_PDB' != '0';

      if PDB_EXP_ != nvl(PDB_CRT_, PDB_EXP_) then
        dbms_output.put_line('SPOOL DB_sql_' || replace(PDB_EXP_, '$', '_') || '_001.log');
        dbms_output.put_line('PROMPT DB: LMS-02018: ERROR: Cannot connect user ' || USER || ' to PDB: ' || PDB_EXP_ || '. Still connected to ' || PDB_CRT_ || '.');
        dbms_output.put_line('SPOOL OFF');
        return;
      elsif PDB_CRT_ is not null then
        dbms_output.put_line('PROMPT Connected to PDB: ' || PDB_CRT_);
      end if;
  EXCEPTION
    when others then
      ERR_C := SQLCODE;
      ERR_M := SUBSTR(SQLERRM, 1 , 500);
      dbms_output.put_line('REM CON_NAME CHECK: SQLCODE: ' || to_char(ERR_C) || ': ' || ERR_M);
  END;

  -- Check if DB collection is needed
  if '~' ||  upper('&&SCRIPT_PRODUCTS') || '~' like '%~DB~%' then
    dbms_output.put_line('PROMPT Collecting database usage information with Review Lite script ...');
    dbms_output.put_line('@ReviewLite.sql');
    dbms_output.put_line('@DBAFUSExtract.sql');
  end if;

  -- Check if this is an EBS database and if EBS collection is needed
  BEGIN
    execute immediate 'select trim(min(decode(OWNER, ''APPS'', '' APPS'', OWNER))) from DBA_OBJECTS a where a.OBJECT_NAME = ''FND_PRODUCT_GROUPS'' and a.OBJECT_TYPE in (''SYNONYM'') and ''~'' || upper(''&&SCRIPT_PRODUCTS'') || ''~'' like ''%~EBS~%''' into EBS_SCHEMA;

    if  EBS_SCHEMA is not null then
      dbms_output.put_line('PROMPT Collecting EBS data from SCHEMA [' || EBS_SCHEMA || '] ...');
      dbms_output.put_line('@EBSCollection.sql');
    end if;

  EXCEPTION
    when others then
      ERR_C := SQLCODE;
      ERR_M := SUBSTR(SQLERRM, 1 , 500);
      dbms_output.put_line('REM EBS CHECK: SQLCODE: ' || to_char(ERR_C) || ': ' || ERR_M);
  END;
END;
/
spool off
show errors

--PROMPT SCRIPT_SI=[&&SCRIPT_SI]
SET TERMOUT ON
--PAUSE Press ENTER >
@@temp2.sql
