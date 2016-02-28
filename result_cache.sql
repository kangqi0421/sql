Result cache
  * PL/SQL Function Result Cache 
  * SQL result cache - hint /*+ result_cache */
 
* SQL Query Result Cache. Includes: [Video] (Doc ID 1108133.1)

-- objekty v result cache nebo použít name pro konkrétní objekt
select count(*) from V$RESULT_CACHE_OBJECTS; 

-- memory result cache report
SET SERVEROUTPUT ON;
execute DBMS_RESULT_CACHE.MEMORY_REPORT(TRUE);

-- shared pool
SELECT * FROM gv$sgastat WHERE POOL='shared pool' AND NAME LIKE 'Result%' AND INST_ID =1;

-- result cache objects
SELECT INST_ID INT, ID, TYPE, CREATION_TIMESTAMP, BLOCK_COUNT, COLUMN_COUNT, PIN_COUNT, ROW_COUNT FROM GV$RESULT_CACHE_OBJECTS;

-- RAC Considerations
Each node in a RAC configuration has a private result cache. There is no Global Result cache.

-- flush result cache
-- run the following code on each instance.
BEGIN
  DBMS_RESULT_CACHE.bypass(TRUE);
  DBMS_RESULT_CACHE.flush;
END;
/