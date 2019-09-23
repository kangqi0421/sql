sqlplus system/s

SET serveroutput ON;

BEGIN
  DBMS_SCHEDULER.DROP_JOB (job_name => 'JOB_DIR_LIST');
  DBMS_SCHEDULER.DROP_PROGRAM('DIR_LIST_PROGRAM');
END;
/


BEGIN
  DBMS_SCHEDULER.CREATE_PROGRAM (
  program_name=> 'DIR_LIST_PROGRAM',
  program_type=> 'EXECUTABLE',
  program_action => '/tmp/dir_list.sh',
  enabled=> TRUE,
  comments=> 'run ls command'
  );
END;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
  job_name => 'JOB_DIR_LIST',
  program_name => 'DIR_LIST_PROGRAM',
  start_date => NULL,
  repeat_interval => NULL,
  end_date => NULL,
  enabled => FALSE,
  auto_drop => FALSE,
  comments => '');
END;
/

BEGIN
  DBMS_SCHEDULER.RUN_JOB('job_dir_list',use_current_session => TRUE);
END;
/

**
--
ERROR at line 1:
ORA-27369: job of type EXECUTABLE failed with exit code: 274662 Oracle
Scheduler error: Config file is not owned by root or is writable
ORA-06512: at "SYS.DBMS_ISCHED", line 209
ORA-06512: at "SYS.DBMS_SCHEDULER", line 594
ORA-06512: at line 2

export ORACLE_HOME=/oracle/product/db/12.1.0.2

ls -l $ORACLE_HOME/rdbms/admin/externaljob.ora
-rw-r--r-- 1 root dba 1534 Dec 21  2005 /oracle/product/db/12.1.0.2/rdbms/admin/externaljob.ora

$ORACLE_HOME/bin/extjob file must be owned by root:oraclegroup but must be setuid i.e. 4750 (-rwsr-x---)

chmod 4750 $ORACLE_HOME/bin/extjob

$ORACLE_HOME/bin/extjobo should have normal 755 (rwxr-xr-x) permissions and be owned by oracle:oraclegroup

ls -l $ORACLE_HOME/bin/extjob*







