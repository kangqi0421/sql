-- změní hodnotu PASSWORD_LIFE_TIME na 270, pokud je hodnota nižší mimo UNLIMITED
BEGIN
  for c in (select LIMIT
    from dba_profiles
   where profile = 'DEFAULT' and RESOURCE_NAME = 'PASSWORD_LIFE_TIME' and limit not in('UNLIMITED', 'DEFAULT'))
  LOOP
    if c.LIMIT <= 270
      then
        execute immediate 'alter profile DEFAULT limit PASSWORD_LIFE_TIME 270';
    end if;
  END LOOP;
END;
/

-- expire default passwords
BEGIN
  FOR rec IN
  (
    SELECT DISTINCT u.name username
      FROM SYS.user$ u          -- vsechny existujici ucty
      JOIN SYS.default_pwd$ dp  -- vsechny registrovane default ucty
      ON (u.name        = dp.user_name)
      WHERE u.type#     = 1
        AND u.name NOT IN ('XS$NULL', 'OJVMSYS') -- ucet fyzicky neexistuje
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
