--------------------------------------------------------
-- Generate DDL for GIT
--------------------------------------------------------

set long 200000 LONGCHUNKSIZE 20000 pages 0 lin 32767
set trims on head off feed off verify off
col cmd for a32767

execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);

--------------------------------------------------------
--  DDL for Package CLONING_API
--------------------------------------------------------

define package_name = CLONING_API

spool &package_name..pks
SELECT DBMS_METADATA.GET_DDL('PACKAGE', '&package_name', 'CLONING_OWNER') as cmd FROM DUAL;
spool off

spool &package_name..pkb
SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', '&package_name', 'CLONING_OWNER') as cmd FROM DUAL;
spool off


--------------------------------------------------------
--  DDL for Package CLONING_REST_CALLS
--------------------------------------------------------

define package_name = CLONING_REST_CALLS

spool &package_name..pks
SELECT DBMS_METADATA.GET_DDL('PACKAGE', '&package_name', 'CLONING_OWNER') as cmd FROM DUAL;
spool off

spool &package_name..pkb
SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', '&package_name', 'CLONING_OWNER') as cmd FROM DUAL;
spool off

exit
