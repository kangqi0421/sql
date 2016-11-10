BEGIN
  FOR rec IN
  (
  SELECT  u.username
    FROM dba_users_with_defpwd p INNER JOIN dba_users u
  ON (u.username = p.username)
    where u.username not in ('XS$NULL')  -- nejedna se o realny ucet
    --AND  account_status <> 'OPEN'
  )
  LOOP
    -- expire, lock and change password to random
    execute immediate ('alter user "'||rec.username ||'" identified by "'||
      dbms_random.string('a',14)||ABS(TRUNC(dbms_random.value(0, 9))) ||'"'||
      ' password expire account lock');
  END LOOP;
END;
/

-- default users --> SYS.default_pwd$
BEGIN
  FOR rec IN
  (
    SELECT DISTINCT u.name
      FROM SYS.user$ u          -- vsechny existujici ucty
      JOIN SYS.default_pwd$ dp  -- vsechny registrovane default ucty
      ON (u.name        = dp.user_name)
      WHERE u.type#     = 1
        AND u.name NOT IN ('XS$NULL') -- ucet fyzicky neexistuje
        AND u.astatus   > 0           -- OPEN ucty nezamykej
  )
  LOOP
    -- expire, lock and change password to random
    EXECUTE immediate ('alter user "'||rec.username ||'" identified by "'||
    dbms_random.string('a',14)||ABS(TRUNC(dbms_random.value(0, 9))) ||'"'||
    ' password expire account lock');
  END LOOP;
END;
/