prompt eXplain the execution plan for sqlid &1


--select * from table(dbms_xplan.display_cursor('&1', NULL, 'BASIC +NOTE'));
--select * from table(dbms_xplan.display_cursor('&1', NULL, 'BASIC +NOTE +OUTLINE'));
select * from table(dbms_xplan.display_cursor('&1',null,'LAST +PEEKED_BINDS +PARTITION +OUTLINE'));
--select * from table(dbms_xplan.display_cursor('&1', NULL, 'ALLSTATS LAST +PEEKED_BINDS +OUTLINE +ADAPTIVE'));