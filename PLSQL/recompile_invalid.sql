DECLARE
  exist NUMBER;
BEGIN
  SELECT NVL(COUNT(*),0)
  INTO   exist
  FROM   dba_objects
  WHERE  status = 'INVALID';
  IF exist >= 1 THEN
     sys.utl_recomp.recomp_serial;
  END IF;
END;
/

