--
-- AST
--

BEGIN
  DBMS_AUTO_TASK_ADMIN.ENABLE('sql tuning advisor', null, null );
END;
/

BEGIN
  DBMS_AUTO_SQLTUNE.SET_AUTO_TUNING_TASK_PARAMETER('ACCEPT_SQL_PROFILES','TRUE');  -- automaticky akceptuj SQL profily
  DBMS_AUTO_SQLTUNE.SET_AUTO_TUNING_TASK_PARAMETER('TIME_LIMIT', 21600);    -- global timeout na 6 hodin
  DBMS_AUTO_SQLTUNE.SET_AUTO_TUNING_TASK_PARAMETER('LOCAL_TIME_LIMIT',600); -- per statement timeout 10 minut
END;
/

SELECT parameter_name, parameter_value
  FROM   dba_advisor_parameters
WHERE  task_name = 'SYS_AUTO_SQL_TUNING_TASK'
  AND    parameter_name IN ('ACCEPT_SQL_PROFILES',
                          'MAX_SQL_PROFILES_PER_EXEC',
                          'MAX_AUTO_SQL_PROFILES',
                          'TIME_LIMIT',
                          'LOCAL_TIME_LIMIT');