-- ODS DWH
ALL_ODSDWH_ROLES


-- revoke all app role from sys
set pages 0
SELECT   'revoke '||granted_role||' from '||grantee||';'
  FROM dba_role_privs
  WHERE grantee           = 'SYS'
    AND granted_role NOT IN ('DBA', 'RESOURCE', 'CONNECT', 'CSCONNECT')
    AND granted_role     IN
    (
      SELECT   granted_role
        FROM dba_role_privs
        WHERE grantee LIKE 'ALL_ODSDWH_ROLES'
    );