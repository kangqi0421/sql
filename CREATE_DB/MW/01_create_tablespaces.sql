--
-- create tablespaces
--

BEGIN
  EXECUTE IMMEDIATE
    'CREATE BIGFILE TABLESPACE MDW_DATA_TS
       datafile size 512M autoextend on next 512M maxsize UNLIMITED';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -1543 THEN RAISE;
    END IF;
END;
/
