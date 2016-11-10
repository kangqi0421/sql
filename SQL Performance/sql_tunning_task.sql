-- SQL Tunning task DBMS_SQLTUNE

--
-- MOS Doc ID 1082465.1
--
On 11g, switch user occurs for following cases only:
- user is the same as switch user 
- user is SYS
- user is PROXY for the switch user

Otherwise, switching of the user does not occur, and if the user does not have 
object privileges to access the objects referenced in the SQL, ORA-1031 may return. 

--
SET SERVEROUTPUT ON
-- statement from the cursor cache.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '&sql_id',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 300,
                          task_name   => '&&sql_id._tuning_task',
                          description => 'Tuning task for statement &&sql_id');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- AWR
select min(snap_id), max(snap_id) from dba_hist_snapshot;
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
		begin_snap  => 3150,
		end_snap    => 3160,
		sql_id      => '&sql_id',
		scope       => DBMS_SQLTUNE.scope_comprehensive,
		time_limit  => 3600,
--		time_limit  => 300,		
		task_name   => '&&sql_id._tuning_task',
		description => 'Tuning task for statement &&sql_id');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- execute task
EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '&&sql_id._tuning_task');

-- status
SELECT task_name, status FROM dba_advisor_log WHERE task_name = '&&sql_id._tuning_task';
select * from dba_advisor_findings where task_name = '&&sql_id._tuning_task';

-- report
SET LONG 90000
SET LONGCHUNKSIZE 1000
SET PAGESIZE 9999
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('&&sql_id._tuning_task') AS recommendations FROM dual;

SET LONG 90000
SET LONGCHUNKSIZE 1000
SET LINESIZE 150
SET pagesize 9999
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK(:stmt_task) FROM dual;

