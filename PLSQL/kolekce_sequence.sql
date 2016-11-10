//-- plnìní kolekce ze sequence --//

declare
      type ta is table of number index by PLS_INTEGER;
      a ta;
begin
    a(1) := test.NEXTVAL;
    DBMS_Output.PUT_LINE(a(1));
end;
/