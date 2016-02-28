-- TPS - get value of Transactions Per Second

-- promìnnou je interval - poèet sekund, po které chci hodnotu 'user commits' sledovat
-- ve verzi v2 pøidán loop pøes všechny DB instance

SET SERVEROUTPUT ON
DECLARE
    begindate date;
    enddate date;
    beginval number;
    endval number;
    id PLS_INTEGER;

    sleep PLS_INTEGER  := 5;

BEGIN
  dbms_output.put_line('|Inst ID|tps|');		-- header output
  for id in (select INST_ID from gv$instance order by 1) loop
    -- gather #1 stats value
    select sysdate, value
      into begindate, beginval
    from gv$sysstat 
    where name in ('user commits') and inst_id = id.inst_id;

    -- sleep N seconds
    dbms_lock.sleep(sleep);

    -- gather #2 stats value
    select sysdate, value
      into enddate, endval
    from gv$sysstat 
    where name in ('user commits') and inst_id = id.inst_id;

    -- display delta values for each instance
    dbms_output.put_line('|'|| id.inst_id ||'|'|| round((endval-beginval) / ((enddate-begindate) * 86400),1) || 
                          '|');
  end loop;
END;
/

