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


select profile,RESOURCE_NAME, limit
  from dba_profiles where profile like 'PROF_APPL_UNLIMITED';

select username, profile
  from dba_users
 where profile = 'PROF_APPL_UNLIMITED';
*/