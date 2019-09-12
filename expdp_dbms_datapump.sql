set serveroutput ON

DECLARE
  h1 NUMBER;
BEGIN

  -- Create a (user-named) Data Pump job to do a schema export.
  h1 := DBMS_DATAPUMP.OPEN(
      operation   => 'EXPORT',
      job_mode    => 'SCHEMA',
      remote_link => NULL,
      version     => 'LATEST');

  -- Specify a single dump file for the job (using the handle just returned)
  DBMS_DATAPUMP.ADD_FILE(h1,'cloning_owner.dmp','DATA_PUMP_DIR');

  -- log file
  DBMS_DATAPUMP.add_file(handle    => l_dp_handle,
                         filename  => 'test.log',
                         directory => 'DATA_PUMP_DIR',
                         filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE,
                         reusefile => 1);

  -- A metadata filter is used to specify the schema that will be exported.
  -- DBMS_DATAPUMP.METADATA_FILTER(h1, 'SCHEMA_EXPR', 'IN (''CLONING_OWNER'')');
  DBMS_DATAPUMP.METADATA_FILTER(h1, 'SCHEMA_LIST', 'CLONING_OWNER');

  -- exclude stats
  DBMS_DATAPUMP.METADATA_FILTER(h1, 'EXCLUDE_PATH_EXPR', 'IN (''STATISTICS'')');

  -- Start the job. An exception will be generated if something is not set up
  -- properly.
  DBMS_DATAPUMP.START_JOB(h1);
  DBMS_DATAPUMP.WAIT_FOR_JOB(h1, v_job_state);
  DBMS_OUTPUT.PUT_LINE(v_job_state);
  -- DBMS_DATAPUMP.DETACH(h1);
END;
/
