--
-- AWR - zvednout AWR retention na 14 dni
--

WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>20160);
END;
/  