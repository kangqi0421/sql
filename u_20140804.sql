col username for a30
col profile for a14
col default_tablespace for a15
col temporary_tablespace for a8
col status for a45

set head on feedback off verify off

prompt Show database usernames from dba_users matching &1

select 
	--username,
    decode(password,'EXTERNAL', username||':'||external_name, username) username,  -- username:external
	profile,
	default_tablespace, 
	temporary_tablespace, 
	decode(account_status,'OPEN','OPEN',account_status||
		decode(LOCK_DATE, NULL, NULL, ' L:'||LOCK_DATE)||
		decode(EXPIRY_DATE, NULL, NULL, ' E:'||EXPIRY_DATE)) status,
	created
from 
	dba_users 
where 
	upper(username) like upper('&&1')
order by 1;

set head off feedback off

select 'alter user '||username||' account unlock;' 
  from dba_users 
where 
	upper(username) like upper('&&1')
	and account_status <> 'OPEN'
order by username;

-- generate password for change, lowercase + one digit number at the end
select 'alter user '||username
  ||' identified by "'||dbms_random.string('a',7)||ABS(trunc(dbms_random.value(0, 9)))
  ||'"'
  ||' password expire;' 
  from dba_users 
 where upper(username) like upper('&&1')
  and (password is null or password = 'EXTERNAL')	-- mimo heslo ve správě Kerbera
order by username; 

prompt

set head on feedback on
