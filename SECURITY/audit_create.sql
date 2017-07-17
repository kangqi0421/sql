col instance new_value instance
select instance_name||'_audit_create.spool' instance from v$instance;
spool '&instance'

set pages 1000 echo on;
select instance_name from v$instance;

-- set before
select AUDIT_OPTION,SUCCESS,FAILURE from dba_stmt_audit_opts;
SELECT PRIVILEGE AS NAME FROM dba_priv_audit_opts;
SELECT OBJECT_NAME,DEL,UPD FROM dba_obj_audit_opts WHERE object_name = 'AUD$';

audit all by access;
audit all privileges by access;
audit alter sequence by access;
audit alter table by access;
audit comment table by access;
audit delete table by access whenever not successful;
audit execute procedure by access whenever not successful;
audit grant directory by access;
audit grant procedure by access;
audit grant sequence by access;
audit grant table by access;
audit grant type by access;
audit insert table by access whenever not successful ;
audit lock table by access whenever not successful ;
audit select sequence by access whenever not successful;
audit select table by access whenever not successful ;
audit update table by access whenever not successful ;
audit exempt access policy by access;

audit delete on sys.aud$;
audit update on sys.aud$;
audit delete on sys.fga_log$;
audit update on sys.fga_log$;

-- set after
select AUDIT_OPTION,SUCCESS,FAILURE from dba_stmt_audit_opts;
SELECT PRIVILEGE AS NAME FROM dba_priv_audit_opts;
SELECT OBJECT_NAME,DEL,UPD FROM dba_obj_audit_opts WHERE object_name = 'AUD$' or object_name = 'FGA_LOG$';
