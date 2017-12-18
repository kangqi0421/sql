--
-- force logging
--

WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
  v_logging char(3);
BEGIN
  select force_logging into v_logging
    FROM v$database;
  IF v_logging = 'NO' THEN
    execute immediate 'alter database force logging';
  END IF;
END;
/
