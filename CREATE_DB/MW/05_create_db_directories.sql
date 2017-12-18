--
-- create db directories
--

column db_name new_value db_name print
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') as db_name from dual;

create or replace directory MW_CSOPS_ARCHIMP as '/var/csopsd/archiv/import';
create or replace directory MW_CSOPS_IMP as '/var/csopsd/import';
create or replace directory MW_CSOPS_EXP as '/var/csopsd/export';
create or replace directory MW_DB_LOG as '/oradb/logs/&db_name.log';

GRANT WRITE ON DIRECTORY MW_CSOPS_EXP TO MW_DB_SERVER;
GRANT READ ON DIRECTORY MW_CSOPS_IMP TO MW_DB_SERVER;
GRANT READ, WRITE ON DIRECTORY MW_CSOPS_ARCH TO MW_DB_SERVER;
