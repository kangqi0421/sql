--select listagg(DBMS_ASSERT.enquote_literal(username),',') WITHIN GROUP (ORDER BY username) from dba_users
--where username like 'AS1_DISCOVERER%';

def export_users="'&1'"
--def export_users="'MW'"

set long 200000 pages 0 lin 32767 trims on head off feed off verify off
col cmd for a32767

spool Clone_User_&export_users..sql

execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);


select dbms_metadata.get_ddl('USER', username) cmd
  from dba_users
 where upper(username) in upper(&export_users)
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('TABLESPACE_QUOTA', USERNAME) cmd
  FROM DBA_USERS 
 where username in (select username from dba_ts_quotas where upper(username) in (&export_users))
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME) cmd
  FROM DBA_USERS 
 where username in (select grantee from dba_role_privs where upper(grantee) in (&export_users))
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME) cmd
  FROM DBA_USERS 
 where username in (select grantee from dba_sys_privs where upper(grantee) in (&export_users))
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', USERNAME) cmd
  FROM DBA_USERS 
 where username in (select grantee from dba_tab_privs where grantee in (&export_users))
/

spool off




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
