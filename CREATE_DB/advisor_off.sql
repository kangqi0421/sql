--
-- disable space a tunning advisor
--

WHENEVER SQLERROR EXIT SQL.SQLCODE

col client_name for a40
select client_name, status from dba_autotask_client ;

BEGIN
   dbms_auto_task_admin.DISABLE ('auto space advisor', NULL, NULL);
   dbms_auto_task_admin.DISABLE ('sql tuning advisor', NULL, NULL);
END;
/

select client_name, status from dba_autotask_client ;

