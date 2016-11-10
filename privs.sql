col grantee for a25
col granted_role for a40
col type_name for a40
col table_name for a40

-- ROLEs
select grantee, granted_role, admin_option, default_role from dba_role_privs where upper(grantee) like upper('&1') order by grantee, granted_role;

-- SYS privs
select grantee, privilege, admin_option from dba_sys_privs where upper(grantee) like upper('&1') order by grantee, privilege;

-- OBJECT privs
select grantee, owner, table_name, privilege from dba_tab_privs where upper(grantee) like upper('&1') order by grantee, owner, table_name, privilege;

-- COLs privs
select grantee, owner, table_name, privilege, column_name from dba_col_privs where upper(grantee) like upper('&1') order by grantee, owner, table_name, privilege, column_name ;

-- JAVA privs
select grantee, type_schema, type_name, name, action, enabled from dba_java_policy where upper(grantee) like upper('&1') order by grantee, kind, type_name;

/*
-- spool SYS grants
select 'GRANT '||privilege||' to '||grantee||
        decode(admin_option,'YES',' WITH Grant option')||';' CMD
  from dba_sys_privs
 where grantee in ('PDB_OWNER_ROLE')
;
*/
/*
-- spool tab grants
select 'GRANT '||privilege||' "'||owner||'"."'||
table_name||'" to '||grantee||' '||grantable||';' CMD, grantee
from (
select GRANTEE, OWNER, TABLE_NAME,
  case
    when privilege in ('READ','WRITE')  THEN privilege||' ON '||'DIRECTORY'
    else privilege||' ON'
  end privilege,
  decode(grantable,'YES','WITH Grant option') grantable
from dba_tab_privs
)
  where grantee in ('PDB_OWNER_ROLE',')
;

*/