set lines 180
col PROFILE for a20
col LIMIT for a14
col RESOURCE_NAME for a25

select profile, RESOURCE_NAME, limit from dba_profiles
 where upper(profile) like upper('&1')
   and limit not like 'DEFAULT'
order by resource_name, profile;

/*

-- změna profile
alter profile PROF_APPL_UNLIMITED limit IDLE_TIME UNLIMITED;
alter profile PROF_APPL limit IDLE_TIME UNLIMITED;

alter profile PROF_APPL limit
  PASSWORD_GRACE_TIME 7 PASSWORD_LIFE_TIME 413;

-- vypnutí uzamčení účtu při změně hesla
alter profile PROF_APPL limit FAILED_LOGIN_ATTEMPTS UNLIMITED;

select profile,RESOURCE_NAME, limit
  from dba_profiles
 where profile like 'PROF_APPL'
-- where profile = 'PROF_APPL_UNLIMITED';
;


select username, profile from dba_users;

select username, profile from dba_users
  where REGEXP_LIKE(username, '^[A-Z]{1,3}\d{4,}$');

*/

--
/*
begin
  for rec in (
   select username  from dba_users
      where REGEXP_LIKE(username, '^[A-Z]{1,3}\d{4,}$')
  AND profile not in ('PROF_USER', 'PROF_DBA'))
    loop
      execute immediate 'alter user '||rec.username|| ' profile PROF_USER';
    end loop;
end;
/

*/