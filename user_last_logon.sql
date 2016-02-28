select u.username, u.account_status, a.last_logon
  from sys.dba_users u,
   (
    select username, max(timestamp) as last_logon
      from dba_audit_session
      where returncode = 0
      group by username
    ) a
  where u.username = a.username(+)
  order by 1;
