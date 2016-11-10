@/dba/local/sql/SECURITY/audit12c/CS_dba_create_audit_policy.sql
@/dba/local/sql/SECURITY/audit12c/CS_dba_setup_audit_policy.sql
@/dba/local/sql/SECURITY/audit12c/CS_dba_SYS_policy.sql

-- show parameter audit
select value from v$option where parameter = 'Unified Auditing';

-- enabled policies
set lines 2000 pages 2000
col USER_NAME for A30
col POLICY_NAME for A30
select * from AUDIT_UNIFIED_ENABLED_POLICIES order by POLICY_NAME, USER_NAME, ENABLED_OPT, SUCCESS, FAILURE;
