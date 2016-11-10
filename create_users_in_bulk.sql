--
-- CREATE, ALTER, GRANT, UNLOCK, PASSWORD
--

def users="'EXT94623','EXT94210','EXT93159'"
def role="PDB_READONLY"


SET serveroutput ON linesize 180

DECLARE
  v_profile         dba_users.profile%type              := 'PROF_USER';
  v_def_tablespace  dba_users.DEFAULT_TABLESPACE%type   := 'USERS';
TYPE username_tab
IS
  TABLE OF VARCHAR2 (8);
  names username_tab := username_tab (
  &users
  ) ;
  user_conflict EXCEPTION; -- odchyt expception, pokud uzivatel jiz existuje
  PRAGMA EXCEPTION_INIT(user_conflict, -1920);
BEGIN
  FOR i IN names.FIRST .. names.LAST
  LOOP
    BEGIN
      -- CREATE USER
      EXECUTE IMMEDIATE 'CREATE USER '||names (i)||
      ' identified externally as '||
      DBMS_ASSERT.enquote_literal(lower(names(i))||'@CEN.CSIN.CZ') ||
	    ' PROFILE '||v_profile;
      DBMS_OUTPUT.PUT_LINE(names (i)||' created');
    EXCEPTION
    WHEN user_conflict THEN
      -- potlac exception, pokud uzivatel jiz existuje
      DBMS_OUTPUT.PUT_LINE('user already exist');
      --NULL;
    WHEN OTHERS THEN
      raise;
    END;
    -- GRANTS CRM
    EXECUTE IMMEDIATE 'GRANT CSCONNECT, &role TO '|| names (i);
    --EXECUTE IMMEDIATE 'GRANT CSCONNECT, ASCARD_READ_ONLY,CBL_READ_ONLY,ASEBPP_READ_ONLY,DBMAIN_READ_ONLY,ARM_READONLY,ASS24_READ_ONLY,ASB24_READ_ONLY,ASDON_READ_ONLY,ASCS_READ_ONLY,ASSOCKA_READ_ONLY,ASCBL_READ_ONLY,CBL_CONNECT,DBIMPORT_READ_ONLY,DBEIM_READ_ONLY,EPM_READONLY,DBRPTM_READ_ONLY TO '|| names (i);
    -- ALTER USER
    -- EXECUTE IMMEDIATE 'ALTER USER ' ||names (i) || ' QUOTA 50M on '||v_def_tablespace;
    -- UNLOCK accounts
    -- EXECUTE IMMEDIATE 'ALTER USER ' ||names (i) || ' ACCOUNT UNLOCK';
    -- CHANGE password to "<USERNAME>1234"
    -- EXECUTE IMMEDIATE 'ALTER USER ' ||names (i) || ' IDENTIFIED BY "'||TRIM(names (i))||'1234"';
    --dbms_output.put_line( 'ALTER USER ' ||names (i) || ' IDENTIFIED BY "'||
    -- TRIM(names (i))||'1234"');
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  raise;
END;
/

set lines 180
col username for a10
col EXTERNAL_NAME for a20
col ACCOUNT_STATUS a10
col PROFILE for a10
SELECT
  username, EXTERNAL_NAME,
  account_status,
  profile
FROM
  dba_users
WHERE
  username IN ( &users );


-- revoke ROLESDECLARE
TYPE username_tab
IS
  TABLE OF VARCHAR2 (16);
  names username_tab := username_tab ('EXT92111','CEN78415','CEN35971','CEN36832','EXT92910','EXT93243','EXT94176') ;
BEGIN
  FOR i IN names.FIRST .. names.LAST
  LOOP
    EXECUTE IMMEDIATE 'ALTER USER '||names (i)||' account lock';
    for rec in (select granted_role from dba_role_privs where grantee = names (i))
    LOOP
      EXECUTE IMMEDIATE 'REVOKE '||rec.granted_role||' FROM '||names (i);
    END LOOP;
  END LOOP;
END;
/