create or replace type tn is table of number;
/

CREATE OR REPLACE procedure SRBA.test_type as 
       n tn;
begin
      select * bulk collect into n 
      from ( select 1144 nr from dual
             union
             select 1004 nr from dual
            );
      for i in (select column_value nr 
               from   table(n)
               ) 
     loop
       dbms_output.put_line('got it: '||i.nr);
     end loop;
end;
/