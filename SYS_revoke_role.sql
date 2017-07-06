--
-- SYS revoke app role
--

BEGIN
FOR rec IN (
    select granted_role from dba_role_privs
     where grantee = 'SYS'
        and granted_role in (select role from dba_roles where ORACLE_MAINTAINED = 'N')
        and granted_role not in ('DBA')
           )
LOOP
  execute immediate 'REVOKE '||rec.granted_role||' FROM SYS';
END LOOP;
END;
/


select granted_role from dba_role_privs
 where grantee = 'SYS'
;


select role from dba_roles where ORACLE_MAINTAINED = 'N';