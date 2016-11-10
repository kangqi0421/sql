-- co se audituje ? 
select 
  count(*)
--AUDIT_OPTION, SUCCESS, FAILURE 
  from dba_stmt_audit_opts
-- where audit_option in ('ALTER DATABASE','ALTER TABLE')
--   where audit_option like '%GRANT%'
 order by 1
 ;
 
SELECT *
   -- PRIVILEGE AS NAME 
   FROM dba_priv_audit_opts
-- where PRIVILEGE in ('ALTER DATABASE','ALTER TABLE')
   where privilege like '%REVOKE%'
 order by 1
 ;

-- vìtšinou pouze AUD$ a FGA_LOG$
select * from DBA_OBJ_AUDIT_OPTS;

-- default audit opts
SELECT * FROM all_def_audit_opts;

-- query audit data
-- session 
SELECT USERNAME, LOGOFF_TIME, LOGOFF_LREAD, LOGOFF_PREAD,
    LOGOFF_LWRITE, LOGOFF_DLOCK
    FROM DBA_AUDIT_SESSION;

-- objekty
SELECT * FROM DBA_AUDIT_OBJECT;

-- smazani ANY CLIENT z AUDIT$ 
delete from SYS.AUDIT$ where user# = 0 and proxy# is null;

-- IPX audit pøes emcli
select 'AUDIT:'||sys_context('USERENV', 'DB_NAME')||':'||AUDIT_OPTION||':'||SUCCESS||':'||FAILURE from dba_stmt_audit_opts
 where audit_option in ('ALTER DATABASE','ALTER TABLE')
 order by 1
 ;

-- Lists audit trail entries produced BY AUDIT NOT EXISTS
select * from DBA_AUDIT_EXISTS;