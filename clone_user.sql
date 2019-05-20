--select listagg(DBMS_ASSERT.enquote_literal(username),',') WITHIN GROUP (ORDER BY username) from dba_users
--where username like 'AS1_DISCOVERER%';

def export_users="'&1'"
-- def export_users="'PMWDT1','WCRT2','WCRT2WORK'"
def export_users="'CPT_APP','CPTPK_APP','CONSOLE_APP','JOB_APP','LOG_APP'"

set long 2000000000 pages 0 lin 32767 trims on head off feed off verify off
set longchunksize 32000

col cmd for a32767

-- tablespaces
define maxsize = 32767
define max_pocet_datafiles = 4

WITH tbs AS (
  SELECT tablespace_name,
         SUM(bytes)/1048576 size_mb
    FROM dba_data_files
      WHERE
         tablespace_name in (
    select unique tablespace_name
      from dba_segments
        where owner in (&export_users)
    union
    select default_tablespace
      from dba_users
       where username in (&export_users)
                            )
  GROUP BY tablespace_name ORDER BY tablespace_name
  )
SELECT 'CREATE '||
  CASE
    WHEN size_mb > &maxsize * &max_pocet_datafiles THEN 'BIGFILE '
    ELSE ''
  END ||
    'TABLESPACE '||tablespace_name||
    ' datafile size 512M autoextend on next 512M maxsize '||
  CASE
    WHEN size_mb > &maxsize * &max_pocet_datafiles THEN 'UNLIMITED'
    ELSE '&maxsize.M'
  END  || ';'
  -- ROUND(GREATEST(size_mb, &maxsize)) ||'M;'
  END
FROM TBS;


-- create roles
select
   'create role '||ROLE||';'
  from dba_roles
    where oracle_maintained = 'N'
     AND (
   role like 'PAD%'
)
order by 1
;



spool Clone_User_&export_users..sql

execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);


select dbms_metadata.get_ddl('USER', username) cmd
  from dba_users
 where username in (&export_users)
order by 1
/

-- bulk create user
select 'CREATE USER '|| DBMS_ASSERT.enquote_name(username) ||
         ' identified by ' || DBMS_ASSERT.enquote_name(username || 'ABCD1234') ||
         ' profile PROF_APPL ' ||
         ' default tablespace ' || default_tablespace ||
         ' quota unlimited on ' || default_tablespace ||
         ';'
  from dba_users
 where username in (&export_users)
order by 1
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('TABLESPACE_QUOTA', USERNAME) cmd
  FROM DBA_USERS
 where username in (select username from dba_ts_quotas where username in (&export_users))
order by 1
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME) cmd
  FROM DBA_USERS
 where username in (select grantee from dba_role_privs where grantee in (&export_users))
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME) cmd
  FROM DBA_USERS
 where username in (select grantee from dba_sys_privs where grantee in (&export_users))
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', USERNAME) cmd
  FROM DBA_USERS
 where username in (select grantee from dba_tab_privs where grantee in (&export_users))
/

--
--
spool off

--
--


-- bulk roles
## grant roles

select 'GRANT '||priv|| ' to '|| grantee ||';'
from (
select granted_role priv, grantee
  from dba_role_privs
 where grantee in (&export_users)
UNION
select privilege priv, grantee
  from dba_sys_privs
 where grantee in (&export_users)
order by 2, 1
);

## system granty

select 'GRANT '||privilege||' to '||grantee||
        decode(admin_option,'YES',' WITH Grant option')||';' CMD
  from dba_sys_privs
 where (grantee like 'CPT%'
or grantee like 'CPTPK%'
or grantee like 'CPTPKMASTER%'
or grantee like 'CPTTOOL%'
or grantee like 'LOG%'
or grantee like 'JOB%'
or grantee like 'CONSOLE%'
or grantee like 'FAKEDWH%')
 order by grantee, privilege
;

-- PASSWORDS
/*
select 'alter user '||username||
   ' identified by "'||
   dbms_random.string('a',1)||dbms_random.string('x',7)||'";'
  from dba_users
 where username in (&export_users);

-- password as like as username
select 'alter user '||username||' identified by "'||lower(username)||'";' from dba_users where username in (&export_users);
*/

/*
--// export roles //--

-- Create the roles
SELECT DBMS_METADATA.GET_DDL('ROLE', role)||';'
  FROM dba_roles
where role like 'GECCC_CMP_READ_ONLY'
/

-- Roles which are granted to roles
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', role)
  FROM role_role_privs
where role like 'GECCC_CMP_READ_ONLY'
/

-- System privileges granted to roles
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', role)
  FROM ROLE_SYS_PRIVS
where role like 'GECCC_CMP_READ_ONLY'
/

-- Table privileges granted to roles
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', role)
  FROM ROLE_TAB_PRIVS
where role like 'GECCC_CMP_READ_ONLY'
/

*/

--// export java privs //--
column stmt format a70 word_wrapped
select 'exec '||stmt
from (select seq, 'dbms_java.grant_permission('''||grantee||''','''||
             type_schema||':'||type_name||''','''||name||''','''||action||
             ''');' stmt
      from sys.dba_java_policy
      where grantee in (&export_users)
	    and type_name!='oracle.aurora.rdbms.security.PolicyTablePermission'
      union all
      select seq,'dbms_java.grant_policy_permission('''||a.grantee||''','''||
             u.name||''','''||permition||''','''||action||''');' stmt
      from sys.user$ u,
           (select seq, grantee,
                   to_number(substr(name,1,instr(name,':')-1)) userid,
                   substr(name,instr(name,':')+1,instr(name,'#') -
                          instr(name,':')-1) permition,
                   substr(name,instr(name,'#')+1 ) action
            from sys.dba_java_policy
            where grantee in (&export_users)
                  and type_name = 'oracle.aurora.rdbms.security.PolicyTablePermission') a
      where u.user#=userid) order by seq;


