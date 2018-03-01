--
-- create db directories
--

define env_status = prod

column db_name new_value db_name print
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') as db_name from dual;

-- create or replace directory MW_DB_LOG as '/oradb/logs/&db_name.log';

create or replace directory MW_CSOPS_EXP as '/srv/data/&env_status/csops/csopsd/remote/csopsd/export/&db_name.P1';
create or replace directory MW_CSOPS_IMP as '/srv/data/&env_status/csops/csopsd/remote/csopsd/import/&db_name.P1';
create or replace directory MW_CSOPS_ARCH as '/srv/data/&env_status/csops/csopsd/remote/csopsd/archiv/&db_name.P1';

GRANT WRITE ON DIRECTORY MW_CSOPS_EXP TO MW_DB_SERVER;
GRANT READ ON DIRECTORY MW_CSOPS_IMP  TO MW_DB_SERVER;
GRANT READ, WRITE ON DIRECTORY MW_CSOPS_ARCH TO MW_DB_SERVER;

-- drop directory
BEGIN EXECUTE IMMEDIATE 'drop directory MW_ORA_APP_IMP_LOGS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'drop directory MW_CSOPS_ARCHIMP'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


-- JAVA permission
-- nutno oddělit read a write na samostatný řádek

-- MW
/*
BEGIN
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export','read');
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export', 'write');
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export', 'delete');
END;
/
*/

-- DBEIM java granty
BEGIN
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/export/MDWPP1','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/export/MDWPP1/*','delete');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/export/MDWPP1/*','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/export/MDWPP1/*','write');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/import/MDWPP1','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/import/MDWPP1/*','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/srv/data/prod/csops/csopsd/remote/csopsd/import/MDWPP1/*','write');
END;
/
