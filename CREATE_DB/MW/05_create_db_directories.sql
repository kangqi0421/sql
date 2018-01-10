--
-- create db directories
--

column db_name new_value db_name print
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') as db_name from dual;

create or replace directory MW_CSOPS_IMP as '/var/csopsd/import';
create or replace directory MW_CSOPS_EXP as '/var/csopsd/export';
create or replace directory MW_DB_LOG as '/oradb/logs/&db_name.log';

GRANT WRITE ON DIRECTORY MW_CSOPS_EXP TO MW_DB_SERVER;
GRANT READ ON DIRECTORY MW_CSOPS_IMP TO MW_DB_SERVER;
GRANT READ, WRITE ON DIRECTORY MW_CSOPS_ARCH TO MW_DB_SERVER;

-- drop directory
BEGIN EXECUTE IMMEDIATE 'drop directory MW_ORA_APP_IMP_LOGS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'drop directory MW_CSOPS_ARCHIMP'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


-- JAVA permission
-- nutno oddělit read a write na samostatný řádek

-- MW
BEGIN
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export','read');
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export', 'write');
  dbms_java.grant_permission('MW', 'SYS:java.io.FilePermission', '/var/csopsd/export', 'delete');
END;
/

-- DBEIM
BEGIN
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/export','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/export/*','delete');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/export/*','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/export/*','write');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/import','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/import/*','read');
  dbms_java.grant_permission('DBEIM','SYS:java.io.FilePermission','/var/csopsd/import/*','write');
END;
/
