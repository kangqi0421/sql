--// change password/lock of user SRBA //--

-- SQL verze

/*
def username=SRBA

set VERIFY OFF termout off feedback off trimspool on trimout on

create user &username IDENTIFIED BY abcd1234;
alter user &username identified by "EU6sIVHrXN1dfgIIUUI8";
alter user &username account lock;
alter user &username profile PROF_DBA;
revoke dba from &username;
grant create session to &username;

select username, account_status from dba_users where username = '&username';

-- posunutí expirace
alter user &username profile DEFAULT;
alter user &username identified by "jiri123cek";
alter user &username profile PROF_DBA;

*/


-- PL/SQL verze

def username=SRBA

set serveroutput on


DECLARE
  v_if_exist NUMBER;
  v_username dba_users.username%type;
BEGIN
  -- SOL60210
  v_username := '&username';
  SELECT COUNT(*) INTO v_if_exist
     FROM dba_users  WHERE username = v_username;

  if v_if_exist > 0 THEN
    execute immediate 'drop user '||v_username||' cascade';
  END IF;

  v_username := 'SRBA';
  SELECT COUNT(*) INTO v_if_exist
     FROM dba_users  WHERE username = v_username;

  if v_if_exist = 0 THEN
    execute immediate 'create user '||v_username||' IDENTIFIED BY abcd1234';
  END IF;

  -- change password
  execute immediate 'alter user '||v_username||' IDENTIFIED BY "'||
      dbms_random.string('a',14)||ABS(trunc(dbms_random.value(0, 9)))||'"';
  -- lock account, profile DBA
  execute immediate 'alter user '||v_username||' account lock';
  execute immediate 'alter user '||v_username||' profile PROF_DBA';
  execute immediate 'grant create session to '||v_username;
  execute immediate 'revoke dba from '||v_username;
  EXCEPTION
    WHEN OTHERS THEN
  NULL;
END;
/

select username, account_status from dba_users where username = 'SRBA'
;