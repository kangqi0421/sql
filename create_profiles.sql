set pages 999 trims on lines 120


select profile, limit from dba_profiles where PROFILE in ('DEFAULT','PROF_USER', 'PROF_SUPP') and RESOURCE_NAME in ('PASSWORD_LOCK_TIME','PASSWORD_LIFE_TIME');

-- historické změny oproti standardu
DECLARE
  v_sql VARCHAR(1000);
BEGIN
  for rec in (select name
    from SYS.PROFNAME$
   where name in ('PROF_USER','PROF_SUPP'))
  LOOP
    v_sql := 'ALTER PROFILE '|| rec.name ||' LIMIT
                SESSIONS_PER_USER 8
                PASSWORD_LOCK_TIME 15/1440
                PASSWORD_GRACE_TIME 7 PASSWORD_LIFE_TIME 83';
    -- dbms_output.put_line(v_sql);
    EXECUTE IMMEDIATE v_sql;
  END LOOP;
END;
/

alter profile PROF_SUPP limit
  SESSIONS_PER_USER 8
  password_lock_time 15/1440
  PASSWORD_GRACE_TIME 7 PASSWORD_LIFE_TIME 83;


-- IDLE TIME 240 min
CREATE PROFILE "PROF_USER_PDB"
limit
IDLE_TIME 240
SESSIONS_PER_USER 8
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LOCK_TIME 15/1440
PASSWORD_GRACE_TIME 7
PASSWORD_LIFE_TIME 23
PASSWORD_REUSE_MAX 12
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_VERIFY_FUNCTION
CS_PWD_VERIFY;

-- bez zamykani uctu
alter profile PROF_APPL limit FAILED_LOGIN_ATTEMPTS UNLIMITED;

-- password_lock_time na 15 minut */
alter profile PROF_USER limit password_lock_time 15/1440;
alter profile PROF_SUPP limit password_lock_time 15/1440;
alter profile PROF_DBA limit PASSWORD_LOCK_TIME 15/1440;
alter profile PROF_ADHOC limit PASSWORD_LOCK_TIME 15/1440;

-- PASSWORD_LIFE_TIME dle nového pøedpisu
alter profile PROF_DBA limit PASSWORD_LIFE_TIME 210;
alter profile PROF_USER limit PASSWORD_LIFE_TIME 23;
alter profile PROF_ADHOC limit PASSWORD_LIFE_TIME 23;
alter profile PROF_SUPP limit PASSWORD_LIFE_TIME 23;
alter profile PROF_APPL limit PASSWORD_LIFE_TIME 413;
alter profile PROF_BATCH limit PASSWORD_LIFE_TIME 413;

-- unlimited profile
CREATE PROFILE "PROF_APPL_UNLIMITED"
limit
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_GRACE_TIME UNLIMITED
PASSWORD_LIFE_TIME UNLIMITED
PASSWORD_REUSE_MAX UNLIMITED
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_VERIFY_FUNCTION
CS_PWD_VERIFY;

select profile,  RESOURCE_NAME, limit
  from dba_profiles
 where PROFILE in ('DEFAULT','PROF_USER', 'PROF_SUPP') and RESOURCE_NAME in ('PASSWORD_LOCK_TIME','PASSWORD_LIFE_TIME');

-- FMW%
select username, profile from dba_users where
username like '%_ESS' OR
username like '%_IAU' OR
username like '%_IAU_APPEND' OR
username like '%_IAU_VIEWER' OR
username like '%_MDS' OR
username like '%_SOAINFRA' OR
username like '%_SOAINFRA_NEBR' OR
username like '%_STB' OR
username like '%_UMS' OR
username like '%_WLS' OR
username like '%_WLS_RUNTIME'
;

-- change profile to PROF_APPL
BEGIN
  for c in (
    select username, profile from dba_users where
    username like '%_ESS' OR
    username like '%_IAU' OR
    username like '%_IAU_APPEND' OR
    username like '%_IAU_VIEWER' OR
    username like '%_MDS' OR
    username like '%_SOAINFRA' OR
    username like '%_SOAINFRA_NEBR' OR
    username like '%_STB' OR
    username like '%_UMS' OR
    username like '%_WLS' OR
    username like '%_WLS_RUNTIME'
    )
  LOOP
    if c.profile != 'PROF_APPL'
      then
        execute immediate 'alter user '|| c.username || ' profile PROF_APPL';
    end if;
  END LOOP;
END;
/
