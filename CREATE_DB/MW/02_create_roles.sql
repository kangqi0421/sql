--
-- create roles
--

def roles="'DBEIM_EXT_TABLE_READ_ONLY', 'DBEIM_READ_ONLY', 'DBMAIN_READ_ONLY', 'MON_ESPIS', 'MW_AUDIT', 'MW_CONNECT', 'MW_DB_SERVER', 'MW_DEBUG', 'MW_LOG', 'MW_MAINTENANCE', 'MW_READ_ONLY'"


DECLARE
  v_role         dba_roles.role%type;
  TYPE role_tab
    IS
      TABLE OF VARCHAR2 (128);
      roles role_tab := role_tab (
        &roles
      ) ;
  --
  role_exists EXCEPTION; -- odchyt expception, pokud uzivatel jiz existuje
  PRAGMA EXCEPTION_INIT(role_exists, -1921);
BEGIN
  FOR i IN roles.FIRST .. roles.LAST
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'CREATE ROLE '||roles(i);
    EXCEPTION
      WHEN role_exists THEN
        NULL;
      WHEN OTHERS THEN
        raise;
    END;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  raise;
END;
/


select ROLE
  from dba_roles
 where oracle_maintained = 'N'
 and role not in (
   'ARM_CLIENT_ROLE', 'REDIM_ROLE', 'CSCONNECT','CS_APPL_ACCOUNTS',
   'CS_DBMGMT_ACCOUNTS')
order by 1;
