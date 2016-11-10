prompt eXplain the execution plan from AWR for sqlid &1 plan_hash_value &2

select * from table(dbms_xplan.display_awr('&1',null,null, 'ALL +OUTLINE +ADAPTIVE'));
-- select * from TABLE(dbms_xplan.display_awr('&1', null, null, 'ALLSTATS +PEEKED_BINDS +OUTLINE +ADAPTIVE'));