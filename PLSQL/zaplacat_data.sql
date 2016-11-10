create table t
(id number,
 num number,
 text char(2000)
)
/

insert --/*+APPEND */ 
  into t
 select rownum
  , 100
  , dbms_random.string('A', 2000)
  from dual
  connect by level <= 100
/

commit;

delete from test;

commit;
