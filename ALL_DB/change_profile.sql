set pages 999 trims on lines 120

select profile, limit from dba_profiles where PROFILE in ('DEFAULT','PROF_USER', 'PROF_SUPP') and RESOURCE_NAME in ('PASSWORD_LOCK_TIME','PASSWORD_LIFE_TIME');

alter profile PROF_USER limit password_lock_time 15/1440;
alter profile PROF_SUPP limit password_lock_time 15/1440;

select profile, limit from dba_profiles where profile = 'DEFAULT' and RESOURCE_NAME = 'PASSWORD_LIFE_TIME';
-- změní hodnotu PASSWORD_LIFE_TIME na 270, pokud je hodnota nižší mimo UNLIMITED
BEGIN
  for c in (select LIMIT
    from dba_profiles
   where profile = 'DEFAULT' and RESOURCE_NAME = 'PASSWORD_LIFE_TIME' and limit not in('UNLIMITED', 'DEFAULT'))
  LOOP
    if c.LIMIT <= 270
      then
        execute immediate 'alter profile DEFAULT limit PASSWORD_LIFE_TIME 270';
    end if;
  END LOOP;
END;
/

select profile, limit from dba_profiles where profile = 'DEFAULT' and RESOURCE_NAME = 'PASSWORD_LIFE_TIME';


--