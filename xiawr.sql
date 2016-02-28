prompt eXplain the execution plan from AWR for sqlid &1 

select * from table(dbms_xplan.display_awr('&1',null,null, 'ALL +OUTLINE'));
-- select * from TABLE(dbms_xplan.display_awr('&1', null, null, 'ALLSTATS +PEEKED_BINDS +OUTLINE +ADAPTIVE'));   