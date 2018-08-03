-- no audit pro import

BEGIN
  FOR rec IN
    (SELECT POLICY_NAME, decode(USER_NAME,'ALL USERS','',' BY '||USER_NAME) as username
    FROM AUDIT_UNIFIED_ENABLED_POLICIES)
  LOOP
    EXECUTE immediate 'noaudit policy '||rec.policy_name||' '||rec.username;
end LOOP;
END;
/
