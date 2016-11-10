BEGIN
  execute immediate ('create public synonym blabla for blabla');
  exception when others then
  null;
END;
/

prompt drop index blabla;

DECLARE
  exist NUMBER;
BEGIN
  SELECT NVL(COUNT(*),0)
  INTO   exist
  FROM   user_indexes
  WHERE  index_name = 'BLABLA_IND';
  IF exist >= 1 THEN
     EXECUTE IMMEDIATE('DROP INDEX BLABLA_IND');
  END IF;
END;
/

