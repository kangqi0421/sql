set serveroutput on size 200000

declare
  cursor c1(pocet_dni number := 90) is
    select snap_id from stats$snapshot
        where trunc(snap_time) <= (sysdate - pocet_dni)
        order by snap_id;
    --
        sql_stmt varchar2(100);
        v_rows number := 0;
        v_radek_na_commit number :=100;
begin
  for i in c1() loop
    v_rows := v_rows + 1;
    sql_stmt:= 'DELETE FROM STATS$SNAPSHOT WHERE SNAP_ID = :1';
        execute immediate (sql_stmt) USING i.snap_id;
        --
        if MOD(v_rows,v_radek_na_commit) = 0 then
          v_rows := 0;
          commit;
        end if;

  end loop;
commit;
exception when others then
  dbms_output.put_line(to_char(SQLCODE)||' - '||SQLERRM);
end;
/
