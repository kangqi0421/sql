SET SERVEROUTPUT ON
DECLARE
 lat INTEGER;
 iops INTEGER;
 mbps INTEGER;
BEGIN
  DBMS_RESOURCE_MANAGER.CALIBRATE_IO (max_iops=>iops, max_mbps=>mbps, actual_latency=>lat);
  DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
  DBMS_OUTPUT.PUT_LINE ('latency = ' || lat);
  dbms_output.put_line('max_mbps = ' || mbps);
end;
/
