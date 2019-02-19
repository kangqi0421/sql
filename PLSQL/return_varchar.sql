 CREATE OR REPLACE FUNCTION CallFunc(p1 IN VARCHAR2)
  2    RETURN VARCHAR2 AS
  3  BEGIN
  4    DBMS_OUTPUT.PUT_LINE('CallFunc called with ' || p1);
  5    RETURN p1;
  6  END CallFunc;
  7  /