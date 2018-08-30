--
-- DBA_USERS
--

col username for a30
col profile for a14
col default_tablespace for a15
col temporary_tablespace for a8
col status for a30
col EXPIRY_DATE for a20
col cmd for a999

set head on feedback off verify off

prompt Show database usernames from dba_users matching &1

select
	--username,
    decode(password,'EXTERNAL', username||':'||external_name, username) username,  -- username:external
	profile,
	default_tablespace,
	-- temporary_tablespace,
	decode(account_status,'OPEN','OPEN',account_status||
		decode(LOCK_DATE, NULL, NULL, ' L:'||LOCK_DATE)||
		decode(EXPIRY_DATE, NULL, NULL, ' E:'||EXPIRY_DATE)) status,
	to_char(CREATED, 'YYYY-MM-DD') || '/' ||
    to_char(EXPIRY_DATE, 'YYYY-MM-DD') "CRATED/EXPIRE date"
from
	dba_users
where
	upper(username) like upper('&&1')
order by 1;

set head off feedback off

select 'alter user '||username||' account unlock;' as cmd
  from dba_users
where
	upper(username) like upper('&&1')
	and account_status <> 'OPEN'
order by username;

-- generate password for change, lowercase + one digit number at the end
-- kerberos exception
select
  CASE
    WHEN password = 'EXTERNAL' THEN '!! KERBEROS !! - DO NOT change the password'
    ELSE
    'alter user '||username
  ||' identified by "'||dbms_random.string('a',17)||ABS(trunc(dbms_random.value(0, 9)))
  ||'"'
  ||' account unlock;'
  END as cmd
  from dba_users
 where upper(username) like upper('&&1')
  --and (password is null or password = 'EXTERNAL')	-- mimo heslo ve správě Kerbera
order by username;

-- změna na kerberos
select
    'alter user '||upper(username)||' identified externally as '||
    DBMS_ASSERT.enquote_literal(lower(username)||'@CEN.CSIN.CZ') ||
	' profile PROF_USER;'  as cmd
  from dba_users
where upper(username) like upper('&&1')
       and authentication_type = 'PASSWORD'
       and REGEXP_LIKE(username, '^[A-Z]+\d{4,}$')
order by username;

prompt

set head on feedback on


/*

--
-- reuse password hash
--

-- http://marcel.vandewaters.nl/oracle/security/password-hashes

-- SELECT name, password, spare4 FROM sys.user$ WHERE name='DBEIM';
-- ALTER USER &user IDENTIFIED BY VALUES 'S:333377748712A1D3E7708FC4F39E2A62AFF76F1766508FF96CE7DD34B6AD';

spool change_pass.sql

set lines 32767 pages 0 trims on head off feed off
col name for a10
col password for a20
col spare4 for a9999
col cmd for a999

SELECT 'ALTER USER '||username|| ' profile DEFAULT;' as cmd
   FROM sys.dba_users WHERE username in (
'LOG','RUIAN_APP','RUIAN','MAJA','MAJA_APP','SCACHE','SCACHE_APP','RUIAN','RUIAN_APP','MAJA','MAJA_APP','SCACHE','SCACHE_APP','DISPO_APP','AUTHCODE_APP'
)
order by username;


SELECT 'ALTER USER '||name|| ' IDENTIFIED BY VALUES ' || DBMS_ASSERT.enquote_literal(spare4) ||';' as cmd
   FROM sys.user$ WHERE name in (
'LOG','RUIAN_APP','RUIAN','MAJA','MAJA_APP','SCACHE','SCACHE_APP','RUIAN','RUIAN_APP','MAJA','MAJA_APP','SCACHE','SCACHE_APP','DISPO_APP','AUTHCODE_APP'
)
order by name
;

SELECT 'ALTER USER '||username|| ' profile ' || profile ||';' as cmd
   FROM sys.dba_users WHERE username in (
'LOG','RUIAN_APP','RUIAN','MAJA','MAJA_APP','SCACHE','SCACHE_APP','RUIAN','RUIAN_APP','MAJA','MAJA_APP','SCACHE','SCACHE_APP','DISPO_APP','AUTHCODE_APP'
)
order by username;

spool off


*/

--
-- zmena hesla na puvodni
--
/*

ALTER USER &user profile default;
ALTER USER &user IDENTIFIED BY "xxx";
ALTER USER &user profile PROF_DBA;


*/

