host SET > env.log
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

define SCRIPT_SILENT=NO
define SCRIPT_SILENT=&1
define SCRIPT_PRODUCTS=NONE
define SCRIPT_PRODUCTS=&2

define LOGS=''
define HOST_NAME=UNKNOWN
define INSTANCE_NAME_0=UNKNOWN

define SCRIPT_SI=''
col C new_val SCRIPT_SI noprint
col C noprint
select '_SILENT_MODE' as C from DUAL where upper('&&SCRIPT_SILENT') = 'YES';
col C clear

--{
--Detect SQL*Plus client path separator
--Using some Unix/Linux specific syntax
host echo select \'$PWD\' as PWD_, \'rm\' as RMDEL_, \'/\' as PSEP_ from dual where \'$PWD\' like \'%/%\'\; > psep.sql 2> fii_err.txt

define PWD=*
define RMDEL=del
define PSEP=\
col PWD_   new_val PWD   noprint
col RMDEL_ new_val RMDEL noprint
col PSEP_  new_val PSEP  noprint
-- The query syntax is correct only on Unix/Linux
@psep.sql

--Detect SQL*Plus client hostname
define CHOST=*
col CHOST_  new_val CHOST  noprint
host echo select \'`uname -n`\' as CHOST_ from dual\;  > psep.sql 2> fii_err.txt
@psep.sql
host echo select '%COMPUTERNAME%' as CHOST_ from dual; > psep.sql 2> fii_err.txt
@psep.sql
prompt Client Host=&&CHOST

-- Cleanup
host &&RMDEL psep.sql   2> fii_err.txt
--}

spool temp1.sql
PROMPT REM db_conn_coll_main.sql running with parameters: [&&SCRIPT_SILENT] [&&SCRIPT_PRODUCTS] + [&&SCRIPT_SI] [&&PSEP] [&&RMDEL]

-- Check CDB/PDB BEGIN
DECLARE
  TYPE cur_typ IS REF CURSOR;
  c cur_typ;
  QUERY_PDBS        VARCHAR2(1000);
  ERR_C             NUMBER         := null;
  ERR_M             VARCHAR2(500)  := '';
  IS_CDB            VARCHAR2(3)    := 'NO';
  CRT_CON_ID        NUMBER         := null;
  LOOP_CON          VARCHAR2(300)  := '';
BEGIN

  BEGIN
    -- Check if container database
    execute immediate 'select CDB, sys_context(''USERENV'', ''CON_ID'') from V$DATABASE' into IS_CDB, CRT_CON_ID;
    dbms_output.put_line('REM CDB=' || IS_CDB || ', CON_ID=' || CRT_CON_ID);
    dbms_output.put_line('--------------------------------------------------');


    if  IS_CDB = 'YES' and CRT_CON_ID=1 then
      -- CDB and CDB$ROOT
      QUERY_PDBS := 'select NAME from V$CONTAINERS where OPEN_MODE in (''MOUNTED'', ''READ WRITE'', ''READ ONLY'') and NAME != ''PDB$SEED'' order by CON_ID';

      open C for QUERY_PDBS;
      loop
          fetch c into LOOP_CON;
          exit when C%notfound;
          -- process row here
          dbms_output.put_line('SHOW CON_ID');
          dbms_output.put_line('SHOW CON_NAME');
          dbms_output.put_line('ALTER SESSION SET CONTAINER = ' || LOOP_CON || ';');
          dbms_output.put_line('@@db_conn_coll.sql ' || LOOP_CON);
     end loop;
      close C;
    else
      dbms_output.put_line('@@db_conn_coll.sql 0');
    end if;

  EXCEPTION
    when others then
      ERR_C := SQLCODE;
      ERR_M := SUBSTR(SQLERRM, 1 , 500);

      if     ERR_C = -904 or ERR_C = -2003 then
        -- database version prior to 12.1
        dbms_output.put_line('@@db_conn_coll.sql 0');
      else
        dbms_output.put_line('SET TERMOUT ON');
        dbms_output.put_line('PROMPT SQL ERROR: ' || to_char(ERR_C) || ': ' || ERR_M);
      end if;
  END;

END;
/
spool off
show errors

@@temp1.sql

-- Log warnings if this is not a local collection
SET VERIFY OFF
SPOOL DB_sql_&&LOGS.003.log
DECLARE
  INSTANCE_N        VARCHAR2(900)  := '&&INSTANCE_NAME_0';
  HOST_N            VARCHAR2(200)  := '&&HOST_NAME';
BEGIN
  if HOST_N != '&&CHOST' then
    dbms_output.put_line('DB: LMS-02801: WARNING: LMSCPU information is needed for Host: ' || HOST_N || ' running Database Instance: ' || INSTANCE_N);
  end if;
END;
/
SPOOL OFF

EXIT
