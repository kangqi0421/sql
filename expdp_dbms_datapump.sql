set serveroutput ON

DECLARE
  h1 NUMBER;               -- Data Pump job handle
BEGIN

-- Create a (user-named) Data Pump job to do a schema export.
  h1 := DBMS_DATAPUMP.OPEN('EXPORT','SCHEMA',NULL,'EXPORT_CLONING_OWNER','LATEST');

-- Specify a single dump file for the job (using the handle just returned)
-- and a directory object, which must already be defined and accessible
-- to the user running this procedure.

  DBMS_DATAPUMP.ADD_FILE(h1,'cloning_owner.dmp','DATA_PUMP_DIR');

-- A metadata filter is used to specify the schema that will be exported.

  DBMS_DATAPUMP.METADATA_FILTER(h1, 'SCHEMA_EXPR', 'IN (''CLONING_OWNER'')');

-- Start the job. An exception will be generated if something is not set up
-- properly.

  DBMS_DATAPUMP.START_JOB(h1);
  DBMS_DATAPUMP.DETACH(h1);
END;
/
