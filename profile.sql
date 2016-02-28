col PROFILE for a20
col LIMIT for a14

select profile, RESOURCE_NAME, limit from dba_profiles 
 where upper(profile) like upper('&1')
 and limit not like 'DEFAULT'
order by resource_name, profile;

-- změna profile
-- alter profile PROF_SUPP_MCI limit IDLE_TIME 120;